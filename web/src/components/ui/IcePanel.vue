<script setup lang="ts">
withDefaults(
  defineProps<{
    variant?: 'primary' | 'secondary'
    circle?: boolean
    interactive?: boolean
  }>(),
  {
    variant: 'primary',
    circle: false,
    interactive: false,
  },
)
</script>

<template>
  <div
    class="ice"
    :class="[`ice--${variant}`, { 'ice--circle': circle, 'ice--interactive': interactive }]"
  >
    <span class="ice__sheen" aria-hidden="true"></span>
    <div class="ice__body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.ice {
  --ice-top: 0.6;
  --ice-bottom: 0.72;
  --ice-glow: 0.13;
  position: relative;
  isolation: isolate;
  border-radius: 1.25rem;
  border: 1px solid rgba(212, 231, 247, 0.14);
  background-image:
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='130' height='130'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='130' height='130' filter='url(%23n)' opacity='0.02'/%3E%3C/svg%3E"),
    radial-gradient(
      150% 100% at 50% -25%,
      rgba(203, 227, 246, var(--ice-glow)) 0%,
      transparent 55%
    ),
    linear-gradient(
      180deg,
      rgba(20, 44, 71, var(--ice-top)) 0%,
      rgba(9, 24, 43, var(--ice-bottom)) 100%
    );
  background-repeat: repeat, no-repeat, no-repeat;
  background-size:
    130px 130px,
    cover,
    cover;
  transition:
    --ice-top 0.5s ease,
    --ice-bottom 0.5s ease,
    --ice-glow 0.5s ease,
    border-color 0.5s ease,
    box-shadow 0.5s ease;
  box-shadow:
    0 0 0 1px rgba(233, 244, 253, 0.04),
    0 26px 54px -30px rgba(5, 14, 30, 0.62),
    0 3px 10px -6px rgba(5, 14, 30, 0.5),
    inset 0 1px 0 rgba(233, 244, 253, 0.22),
    inset 0 0 0 1px rgba(233, 244, 253, 0.03),
    inset 0 -24px 46px -34px rgba(5, 14, 30, 0.4);
}

.ice--secondary {
  --ice-top: 0.28;
  --ice-bottom: 0.37;
  --ice-glow: 0.1;
}

.ice--circle {
  border-radius: 9999px;
}

.ice__sheen {
  position: absolute;
  inset: 0;
  z-index: 0;
  border-radius: inherit;
  pointer-events: none;
  background:
    linear-gradient(
      117deg,
      transparent 30%,
      rgba(233, 244, 253, 0.07) 45%,
      rgba(233, 244, 253, 0.02) 51%,
      transparent 63%
    ),
    radial-gradient(80% 55% at 28% 0%, rgba(233, 244, 253, 0.08) 0%, transparent 60%);
}

.ice__body {
  position: relative;
  z-index: 1;
  height: 100%;
}

.ice--interactive {
  cursor: pointer;
}

.ice--interactive:hover {
  border-color: rgba(212, 231, 247, 0.22);
  box-shadow:
    0 0 0 1px rgba(233, 244, 253, 0.06),
    0 30px 60px -30px rgba(5, 14, 30, 0.62),
    0 0 46px -10px rgba(170, 208, 236, 0.18),
    inset 0 1px 0 rgba(233, 244, 253, 0.3),
    inset 0 0 0 1px rgba(233, 244, 253, 0.05),
    inset 0 -24px 46px -34px rgba(5, 14, 30, 0.4);
}
</style>
