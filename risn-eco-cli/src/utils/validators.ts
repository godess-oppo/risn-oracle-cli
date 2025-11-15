export function isNonEmptyString(s: any): boolean {
  return typeof s === "string" && s.trim().length > 0;
}
