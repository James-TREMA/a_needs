<script>
  import { onMount, onDestroy } from 'svelte';
  import HungerBar from './components/HungerBar.svelte';
  import ThirstBar from './components/ThirstBar.svelte';
  
  // État réactif
  let visible = false;
  let hunger = 100;
  let thirst = 100;
  let maxHunger = 100;
  let maxThirst = 100;
  let criticalThreshold = 20;
  let warningThreshold = 40;
  
  // Animations
  let hungerPulse = false;
  let thirstPulse = false;
  
  // Écouter les messages NUI
  function handleMessage(event) {
    const data = event.data;
    
    switch (data.action) {
      case 'update':
        hunger = data.hunger;
        thirst = data.thirst;
        maxHunger = data.maxHunger || 100;
        maxThirst = data.maxThirst || 100;
        criticalThreshold = data.criticalThreshold || 20;
        warningThreshold = data.warningThreshold || 40;
        break;
        
      case 'setVisible':
        visible = data.visible;
        break;
        
      case 'pulse':
        if (data.type === 'hunger') {
          hungerPulse = true;
          setTimeout(() => hungerPulse = false, 500);
        } else if (data.type === 'thirst') {
          thirstPulse = true;
          setTimeout(() => thirstPulse = false, 500);
        }
        break;
    }
  }
  
  onMount(() => {
    window.addEventListener('message', handleMessage);
  });
  
  onDestroy(() => {
    window.removeEventListener('message', handleMessage);
  });
  
  // Calcul des états
  $: hungerPercent = (hunger / maxHunger) * 100;
  $: thirstPercent = (thirst / maxThirst) * 100;
  $: hungerState = hungerPercent <= criticalThreshold ? 'critical' : hungerPercent <= warningThreshold ? 'warning' : 'normal';
  $: thirstState = thirstPercent <= criticalThreshold ? 'critical' : thirstPercent <= warningThreshold ? 'warning' : 'normal';
</script>

<main class:visible>
  <div class="needs-container">
    <HungerBar 
      value={hunger} 
      max={maxHunger} 
      state={hungerState}
      pulse={hungerPulse}
    />
    <ThirstBar 
      value={thirst} 
      max={maxThirst} 
      state={thirstState}
      pulse={thirstPulse}
    />
  </div>
</main>

<style>
  :global(*) {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  
  :global(body) {
    background: transparent;
    overflow: hidden;
    font-family: 'Roboto Condensed', 'Arial Narrow', sans-serif;
  }
  
  main {
    position: fixed;
    /* Position responsive à droite de la minimap GTA */
    bottom: clamp(20px, 2.5vh, 50px);
    left: clamp(230px, 17vw, 380px);
    opacity: 0;
    transform: translateY(20px);
    transition: all 0.3s ease-out;
    pointer-events: none;
  }
  
  main.visible {
    opacity: 1;
    transform: translateY(0);
  }
  
  .needs-container {
    display: flex;
    flex-direction: row;
    gap: 4px;
    align-items: flex-end;
  }
</style>
