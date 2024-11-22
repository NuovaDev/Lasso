// Assist stats for Template Assist

// Define some states for our state machine
STATE_IDLE = 0;

{
	spriteContent: self.getResource().getContent("lasso"),
	initialState: STATE_IDLE,
	stateTransitionMapOverrides: [
		STATE_IDLE => {
			animation: "idle"
		}
	],
	gravity: 0,
	terminalVelocity: 20,
	assistChargeValue:130,
	deathBoundsDestroy:false,
	shadows:false
}
