<script lang="ts">
  import { Badge, Icon, icons, type IconName } from '@siku/ui'
  import type { ChatMessage, ChatMessageType } from '@/lib/chat/types'
  import { VOICES } from '@/lib/chat/voices'
  import { m } from '@/lib/i18n.svelte'
  import { locale } from '@/lib/locale.svelte'

  type BadgeTone = 'neutral' | 'live' | 'info' | 'solid'

  const TYPE_ICONS: Partial<Record<ChatMessageType, IconName>> = {
    info: 'info',
    success: 'check',
    warning: 'alert',
    error: 'close',
  }

  const RANK_TONES: Record<string, BadgeTone> = {
    owner: 'solid',
    dev: 'live',
    admin: 'info',
    mod: 'neutral',
  }

  const RANK_LABELS: Record<string, () => string> = {
    owner: () => m.chat_rank_owner(),
    dev: () => m.chat_rank_dev(),
    admin: () => m.chat_rank_admin(),
    mod: () => m.chat_rank_mod(),
  }

  let { message }: { message: ChatMessage } = $props()

  const isIconName = (value?: string): value is IconName => !!value && value in icons

  const time = $derived(
    new Date(message.timestamp).toLocaleTimeString(locale.current, {
      hour: '2-digit',
      minute: '2-digit',
    }),
  )

  const icon = $derived(isIconName(message.icon) ? message.icon : TYPE_ICONS[message.type])
  const voice = $derived(VOICES[message.type])
</script>

<div class="chat-row chat-row--{message.type}">
  <span class="chat-row__time t-caption">{time}</span>

  {#if voice}
    <Icon name={voice.icon} size="sm" class="chat-row__icon" />
    <Badge tone="live" label={voice.label()} />
    <span class="chat-row__text t-body-sm">{message.text}</span>
  {:else if message.author}
    {#if message.rank}
      <Badge
        tone={RANK_TONES[message.rank] ?? 'neutral'}
        label={RANK_LABELS[message.rank]?.() ?? message.rank}
      />
    {/if}
    <span class="chat-row__author t-body-sm">{message.author}</span>
    <span class="chat-row__text t-body-sm">{message.text}</span>
  {:else}
    <span class="chat-row__system t-body-sm">
      {#if icon}
        <Icon name={icon} size="sm" class="chat-row__icon" />
      {/if}
      <span>{message.text}</span>
    </span>
  {/if}
</div>
