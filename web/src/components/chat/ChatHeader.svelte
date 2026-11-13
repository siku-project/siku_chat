<script lang="ts">
  import { Badge, Hint, Icon } from '@siku/ui'
  import { m } from '@/lib/i18n.svelte'

  let { staff }: { staff: boolean } = $props()
</script>

<div class="chat-head">
  <Icon name={staff ? 'shield' : 'msg'} size="sm" class="text-fg-tertiary" />
  <span class="t-caption uppercase tracking-wider text-fg-secondary">
    {staff ? m.chat_staff_title() : m.chat_title()}
  </span>
  {#if staff}
    <Badge tone="live" label={m.chat_staff_badge()} />
  {/if}
  <div class="ml-auto">
    <Hint keys={['Esc']} label={staff ? m.chat_back() : m.chat_close()} />
  </div>
</div>
