<script>
  export let value = 100;
  export let max = 100;
  export let state = 'normal'; // 'normal', 'warning', 'critical'
  export let pulse = false;
  
  $: percent = Math.max(0, Math.min(100, (value / max) * 100));
</script>

<div class="bar-track" class:pulse class:warning={state === 'warning'} class:critical={state === 'critical'}>
  <div class="bar-fill" style="height: {percent}%">
    <div class="shine"></div>
  </div>
</div>

<style>
  .bar-track {
    position: relative;
    width: 10px;
    height: 80px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 5px;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }
  
  .bar-track.pulse {
    animation: gainPulse 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .bar-track.warning {
    border-color: rgba(255, 140, 0, 0.4);
  }
  
  .bar-track.critical {
    animation: criticalBlink 0.8s ease-in-out infinite;
    border-color: rgba(255, 60, 60, 0.5);
  }
  
  .bar-fill {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    background: #FF9500;
    border-radius: 2px;
    transition: height 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    overflow: hidden;
  }
  
  .bar-track.pulse .bar-fill {
    animation: fillGlow 0.6s ease-out;
  }
  
  .warning .bar-fill {
    background: #FF6B00;
  }
  
  .critical .bar-fill {
    background: #FF3B3B;
  }
  
  .shine {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 100%;
    background: linear-gradient(180deg, 
      rgba(255, 255, 255, 0.3) 0%, 
      rgba(255, 255, 255, 0) 50%,
      rgba(0, 0, 0, 0.1) 100%);
    pointer-events: none;
  }
  
  .bar-track.pulse .shine {
    animation: shineMove 0.6s ease-out;
  }
  
  @keyframes gainPulse {
    0% { transform: scale(1); }
    30% { transform: scale(1.15, 1.05); }
    100% { transform: scale(1); }
  }
  
  @keyframes fillGlow {
    0% { box-shadow: 0 0 0 rgba(255, 149, 0, 0); }
    30% { box-shadow: 0 0 12px rgba(255, 149, 0, 0.8); }
    100% { box-shadow: 0 0 0 rgba(255, 149, 0, 0); }
  }
  
  @keyframes shineMove {
    0% { opacity: 1; transform: translateY(100%); }
    100% { opacity: 0; transform: translateY(-100%); }
  }
  
  @keyframes criticalBlink {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; }
  }
</style>
