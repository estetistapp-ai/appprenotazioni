export const DEFAULT_SALON_ID = "salone_1";

export function getSalonId() {
  return String(process.env.SALON_ID || process.env.NEXT_PUBLIC_SALON_ID || DEFAULT_SALON_ID)
    .trim() || DEFAULT_SALON_ID;
}

export function scopeRecordId(id: string) {
  const base = String(id || "").trim().toLowerCase();
  const salonId = getSalonId();
  if (!base) return salonId;
  return base.startsWith(`${salonId}__`) ? base : `${salonId}__${base}`;
}

export function salonSettingsId() {
  return `${getSalonId()}__settings`;
}
