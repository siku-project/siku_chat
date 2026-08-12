import { i18n } from '@/i18n'

export interface LocalePayload {
  language: string
  translations: Record<string, string>
}

export function applyLocale(payload: LocalePayload): void {
  i18n.global.setLocaleMessage(payload.language, payload.translations)
  i18n.global.locale.value = payload.language
}
