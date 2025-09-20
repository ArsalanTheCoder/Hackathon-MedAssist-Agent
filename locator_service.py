# locator_service_updated.py
import os
import math
import json
import requests
from flask import Flask, request, jsonify, Response
from typing import List, Dict, Optional, Tuple
from pathlib import Path

# Config (no Google required)
OVERPASS_URL = "https://overpass-api.de/api/interpreter"
NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"
PHOTON_URL = "https://photon.komoot.io/api/"
DEFAULT_RADIUS_M = 20000  # search radius in meters
DEFAULT_LIMIT = 5

# Identify yourself for OSM/Overpass
USER_AGENT = os.getenv("LOCATOR_USER_AGENT", "MyLocatorAgent/1.0 (youremail@example.com)")
CONTACT_EMAIL = os.getenv("LOCATOR_CONTACT_EMAIL", "youremail@example.com")
HEADERS = {"User-Agent": USER_AGENT, "From": CONTACT_EMAIL}

# Simple cache
CACHE_PATH = Path(os.getenv("LOCATOR_CACHE_PATH", "locator_cache.json"))
_cache: Dict[str, Dict] = {}

app = Flask(__name__)

# ---------- Cache ----------
def _load_cache():
    global _cache
    if CACHE_PATH.exists():
        try:
            with open(CACHE_PATH, "r", encoding="utf-8") as f:
                _cache = json.load(f)
        except Exception:
            _cache = {}
    else:
        _cache = {}

def _save_cache():
    try:
        with open(CACHE_PATH, "w", encoding="utf-8") as f:
            json.dump(_cache, f)
    except Exception as e:
        print("Warning: failed to save cache:", e)

_load_cache()

# ---------- Utilities ----------
def haversine_m(lat1, lon1, lat2, lon2) -> float:
    R = 6371000.0
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2.0) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def _format_address_from_tags(tags: Dict) -> str:
    parts = []
    if not tags:
        return ""
    for key in ("addr:street", "addr:housenumber", "addr:city", "addr:postcode", "addr:country"):
        v = tags.get(key)
        if v:
            parts.append(v)
    if not parts:
        for key in ("street", "city", "village", "town"):
            v = tags.get(key)
            if v:
                parts.append(v)
    return ", ".join(parts)

# ---------- Geocoding ----------
def geocode_location(location: str) -> Optional[Tuple[float, float, Dict]]:
    key = location.strip().lower()
    if not key:
        return None
    if key in _cache:
        entry = _cache[key]
        try:
            return float(entry["lat"]), float(entry["lon"]), entry.get("meta", {})
        except Exception:
            pass

    params = {"q": location, "format": "jsonv2", "limit": 1, "addressdetails": 1, "extratags": 1}
    try:
        r = requests.get(NOMINATIM_URL, params=params, headers=HEADERS, timeout=10)
        r.raise_for_status()
        data = r.json()
        if data:
            item = data[0]
            lat = float(item["lat"])
            lon = float(item["lon"])
            _cache[key] = {"lat": lat, "lon": lon, "meta": item}
            _save_cache()
            return lat, lon, item
    except Exception as e:
        print("Nominatim geocode error:", e)

    # Photon fallback
    try:
        r2 = requests.get(PHOTON_URL, params={"q": location, "limit": 1}, headers=HEADERS, timeout=8)
        r2.raise_for_status()
        j2 = r2.json()
        hits = j2.get("features") or []
        if hits:
            props = hits[0].get("properties", {})
            coords = hits[0].get("geometry", {}).get("coordinates", [])
            if len(coords) >= 2:
                lon_p, lat_p = coords[0], coords[1]
                _cache[key] = {"lat": lat_p, "lon": lon_p, "meta": props}
                _save_cache()
                return float(lat_p), float(lon_p), props
    except Exception as e2:
        print("Photon fallback error:", e2)

    return None

# ---------- Overpass ----------
def _run_overpass_query(query: str) -> List[Dict]:
    try:
        r = requests.post(OVERPASS_URL, data=query, headers=HEADERS, timeout=30)
        r.raise_for_status()
        return r.json().get("elements", [])
    except Exception as e:
        print("Overpass error:", e)
        return []

def find_pharmacies_overpass(lat: float, lon: float, radius: int = DEFAULT_RADIUS_M, limit: int = DEFAULT_LIMIT) -> List[Dict]:
    phone_keys = ["phone", "contact:phone", "telephone", "tel", "mobile", "contact:mobile"]
    email_keys = ["email", "contact:email", "e-mail"]
    website_keys = ["website", "contact:website"]

    contact_subqueries = []
    for k in phone_keys + email_keys + website_keys:
        contact_subqueries.append(f'node["amenity"="pharmacy"]["{k}"](around:{radius},{lat},{lon});')
        contact_subqueries.append(f'way["amenity"="pharmacy"]["{k}"](around:{radius},{lat},{lon});')
        contact_subqueries.append(f'relation["amenity"="pharmacy"]["{k}"](around:{radius},{lat},{lon});')

    contact_query = "[out:json][timeout:25];(" + "\n".join(contact_subqueries) + ");out center tags;"
    contact_elems = _run_overpass_query(contact_query)

    seen = set()
    results_with_contact = []
    for elem in contact_elems:
        key = f"{elem.get('type')}/{elem.get('id')}"
        if key in seen:
            continue
        seen.add(key)
        if elem.get("type") == "node":
            lat_e, lon_e = elem.get("lat"), elem.get("lon")
        else:
            center = elem.get("center") or {}
            lat_e, lon_e = center.get("lat"), center.get("lon")
        if not lat_e or not lon_e:
            continue
        tags = elem.get("tags") or {}
        name = tags.get("name") or tags.get("shop") or "Pharmacy"
        phone = tags.get("phone") or tags.get("contact:phone") or tags.get("telephone") or tags.get("tel") or tags.get("mobile") or tags.get("contact:mobile")
        email = tags.get("email") or tags.get("contact:email")
        website = tags.get("website") or tags.get("contact:website")
        opening = tags.get("opening_hours")
        addr = {k: v for k, v in tags.items() if k.startswith("addr:") or k in ("postal_code", "city", "village", "street")}
        formatted_addr = _format_address_from_tags(tags) or addr
        dist = haversine_m(lat, lon, float(lat_e), float(lon_e))
        results_with_contact.append({
            "name": name,
            "lat": float(lat_e),
            "lon": float(lon_e),
            "distance_m": round(dist, 1),
            "address_tags": addr,
            "formatted_address": formatted_addr,
            "phone": phone,
            "email": email,
            "website": website,
            "opening_hours": opening,
            "osm_type": elem.get("type"),
            "osm_id": elem.get("id"),
        })

    results_with_contact.sort(key=lambda x: x["distance_m"])
    if len(results_with_contact) >= limit:
        return results_with_contact[:limit]

    all_query = f"""
    [out:json][timeout:25];
    (
      node["amenity"="pharmacy"](around:{radius},{lat},{lon});
      way["amenity"="pharmacy"](around:{radius},{lat},{lon});
      relation["amenity"="pharmacy"](around:{radius},{lat},{lon});
    );
    out center tags;
    """
    all_elems = _run_overpass_query(all_query)
    results_all = []
    for elem in all_elems:
        key = f"{elem.get('type')}/{elem.get('id')}"
        if key in seen:
            continue
        if elem.get("type") == "node":
            lat_e, lon_e = elem.get("lat"), elem.get("lon")
        else:
            center = elem.get("center") or {}
            lat_e, lon_e = center.get("lat"), center.get("lon")
        if not lat_e or not lon_e:
            continue
        tags = elem.get("tags") or {}
        name = tags.get("name") or tags.get("shop") or "Pharmacy"
        phone = tags.get("phone") or tags.get("contact:phone") or tags.get("telephone") or tags.get("tel") or tags.get("mobile") or tags.get("contact:mobile")
        email = tags.get("email") or tags.get("contact:email")
        website = tags.get("website") or tags.get("contact:website")
        opening = tags.get("opening_hours")
        addr = {k: v for k, v in tags.items() if k.startswith("addr:") or k in ("postal_code", "city", "village", "street")}
        formatted_addr = _format_address_from_tags(tags) or addr
        dist = haversine_m(lat, lon, float(lat_e), float(lon_e))
        results_all.append({
            "name": name,
            "lat": float(lat_e),
            "lon": float(lon_e),
            "distance_m": round(dist, 1),
            "address_tags": addr,
            "formatted_address": formatted_addr,
            "phone": phone,
            "email": email,
            "website": website,
            "opening_hours": opening,
            "osm_type": elem.get("type"),
            "osm_id": elem.get("id"),
        })

    results_all.sort(key=lambda x: x["distance_m"])
    merged = results_with_contact + results_all
    final = []
    seen_ids = set()
    for r in merged:
        oid = f"{r.get('osm_type')}/{r.get('osm_id')}"
        if oid in seen_ids:
            continue
        seen_ids.add(oid)
        final.append(r)
        if len(final) >= limit:
            break

    return final

# ---------- Unified ----------
def get_nearest_pharmacies(
    situation: str,
    location_text: str,
    provider: str = "overpass",
    radius_m: int = DEFAULT_RADIUS_M,
    limit: int = DEFAULT_LIMIT,
) -> Dict:
    geo = geocode_location(location_text)
    if not geo:
        return {"status": "error", "message": "Could not geocode location", "results": []}
    lat, lon, geo_meta = geo
    results = find_pharmacies_overpass(lat, lon, radius=radius_m, limit=limit)
    return {
        "status": "ok",
        "provider": "overpass",
        "query_location": {"input": location_text, "lat": lat, "lon": lon, "raw_geocode": geo_meta},
        "situation": situation,
        "results": results,
    }

# ---------- Flask ----------
@app.route("/locator", methods=["POST"])
def locator_endpoint():
    payload = request.get_json(force=True)
    situation = payload.get("situation", "")
    location_text = payload.get("location") or payload.get("city") or payload.get("query")
    if not location_text:
        return jsonify({"status": "error", "message": "No location provided"}), 400
    radius = int(payload.get("radius_m", DEFAULT_RADIUS_M))
    limit = int(payload.get("limit", DEFAULT_LIMIT))
    out_format = (payload.get("format") or "json").lower()

    out = get_nearest_pharmacies(situation, location_text, provider="overpass", radius_m=radius, limit=limit)

    if out.get("status") != "ok":
        return jsonify(out), 200

    if out_format == "pretty":
        lines = []
        loc = out.get("query_location", {})
        header = f"Top {len(out.get('results', []))} pharmacies near {loc.get('input')} (lat={loc.get('lat')}, lon={loc.get('lon')})"
        lines.append(header)
        lines.append("---")
        for i, r in enumerate(out.get("results", []), start=1):
            lines.append(f"{i}. {r.get('name')} — {r.get('distance_m')} m")
            addr = r.get('formatted_address') or r.get('address_tags') or ''
            if isinstance(addr, dict):
                addr = ", ".join([f"{k}:{v}" for k, v in addr.items()])
            lines.append(f"   Address: {addr or 'N/A'}")
            lines.append(f"   Phone: {r.get('phone') or 'N/A'}")
            lines.append(f"   Email: {r.get('email') or 'N/A'}")
            lines.append(f"   Website: {r.get('website') or 'N/A'}")
            lines.append(f"   Opening: {r.get('opening_hours') or 'N/A'}")
            lines.append(f"   Location: {r.get('lat')}, {r.get('lon')}")
            if r.get('osm_type') and r.get('osm_id'):
                lines.append(f"   OSM: {r.get('osm_type')}/{r.get('osm_id')}")
            lines.append("")
        text = "\n".join(lines)
        return Response(text, mimetype='text/plain')

    return jsonify(out)

# Run
if __name__ == "__main__":
    port = int(os.getenv("LOCATOR_PORT", "9002"))
    print(f"Starting locator service on port {port} (provider = Overpass/OSM)")
    print("USER_AGENT:", USER_AGENT)
    print("CONTACT_EMAIL:", CONTACT_EMAIL)
    app.run(host="0.0.0.0", port=port, debug=False)
