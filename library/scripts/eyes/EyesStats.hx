// Animation stats for Assist Template Projectile
{
	spriteContent: self.getResource().getContent("lasso"),
	stateTransitionMapOverrides: [
		PState.ACTIVE => {
			animation: "eyes_neutral"
		}
	],
	ghost:true,
	shadows:false,
	deathBoundsDestroy:false
}
