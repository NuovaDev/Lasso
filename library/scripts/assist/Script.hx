var owner: Character = self.getOwner();
var foe: Character = null;
var ropeSprites = [];
var ropeSegmentLength = 32;
var ropeSegmentWidth = 32;

var ownerX = 0;
var ownerHipY = 0;
var foeX = 0;
var foeHipY = 0;

var foeSprites = { left: null, center: [], right: null };
var edgeSpriteWidth = 7;

var ropeFrame = 1;
var ropeShake = 0;
var ropeStartAnimFinished = false;

var foeDistance = 0;

var fPos = null;
var actualFPos = null;
var oPos = null;
var pullAngle = 0;
var pullStrength = 0;
var pullXSpeed = 0;
var pullYSpeed = 0;
var newPullXSpeed = 0;
var newPullYSpeed = 0;

var knotBall = null;

var eyes = null;
var pupils = null;
var eyesFront = null;
var lookPoint = null;
var lookAngle = null;
var flashTimer = null;

var squee = 2000;
var flashed = false;
var isFlashing = false;
var flashFrames = 5;
var retracting = false;
var retractSpeed = 15;
var pullAnchor = null;
var ending = false;
var retractTimer = 15;

var stretchSound = null;
var brightness = .016;
var palArray = [5];
function initialize() {

	self.setX(owner.getX());
	self.setY(owner.getY() + owner.getEcbLeftHipY());
	if (owner.isFacingLeft()) {
		self.faceLeft();
	}
	stage.getCharactersBackContainer().addChild(self.getViewRootContainer());
}

// // gold vfx variables
var timeBetweenSparkles: Int = 8;
var currentTimeBetweenSparkles = timeBetweenSparkles;

function goldAltLogic() {
	if (currentTimeBetweenSparkles > 0) {
		currentTimeBetweenSparkles--;
	}

	if (currentTimeBetweenSparkles == 0 && ropeSprites.length > 0) {
		var index = Math.floor(Random.getInt(0, ropeSprites.length - 1));
		var selectedSprite = ropeSprites[index];
		var sparkleX, sparkleY;
		if (Math.abs(Math.cos(selectedSprite.rotation * Math.PI / 180)) > 0.5) {
			sparkleX = selectedSprite.x + Random.getInt(0, 32);
			sparkleY = selectedSprite.y + Random.getInt(-5, 6);
		} else {
			sparkleX = selectedSprite.x + Random.getInt(-5, 6);
			sparkleY = selectedSprite.y + Random.getInt(0, 32);
		}

		var sparkle = match.createVfx(new VfxStats({ spriteContent: "global::vfx.vfx", animation: "vfx_gold_sparkle", x: sparkleX, y: sparkleY }));
		stage.getCharactersBackContainer().addChild(sparkle.getViewRootContainer());
		if (self.getCostumeIndex() == 4) {
			var silverShader = new HsbcColorFilter();
			silverShader.saturation = -1;
			sparkle.addFilter(silverShader);
		}
		currentTimeBetweenSparkles = timeBetweenSparkles;
	}
}

// var foeSprites = { left: null, center: [], right: null };

function flash() {
	var brightness = .5;
	flashFrames = 5;
	isFlashing = true;

	for (sprite in ropeSprites) {
		var filter = new HsbcColorFilter();
		filter.brightness = brightness;
		sprite.addFilter(filter);
		self.addTimer(5, 1, function () {
			sprite.removeFilter(filter);
		}, { persistent: true });
	}
	var filter1 = new HsbcColorFilter();
	filter1.brightness = brightness;
	foeSprites.left.addFilter(filter1);
	self.addTimer(5, 1, function () {
		foeSprites.left.removeFilter(filter1);
	}, { persistent: true });

	var filter2 = new HsbcColorFilter();
	filter2.brightness = brightness;
	foeSprites.right.addFilter(filter2);
	self.addTimer(5, 1, function () {
		foeSprites.right.removeFilter(filter2);
	}, { persistent: true });

	var filter3 = new HsbcColorFilter();
	filter3.brightness = brightness;
	knotBall.addFilter(filter3);
	self.addTimer(5, 1, function () {
		knotBall.removeFilter(filter3);
	}, { persistent: true });

	for (sprite in foeSprites.center) {
		var filter = new HsbcColorFilter();
		filter.brightness = brightness;
		sprite.addFilter(filter);
		self.addTimer(5, 1, function () {
			sprite.removeFilter(filter);
		}, { persistent: true });
	}
	self.addTimer(1, 5, function () {
		flashFrames--;
	}, { persistent: true });
	self.addTimer(5, 1, function () {
		isFlashing = false;
	}, { persistent: true });
}

function init() {
	upatePositions();
	buildRope();
	foeSprites = buildWrap(foe, foeSprites);
}

function upatePositions() {
	if (retracting == true) {
		ownerX = owner.getX();
		ownerHipY = owner.getY() + owner.getEcbRightHipY();
		foeX = pullAnchor.getX();
		foeHipY = pullAnchor.getY();

		if (owner.isFacingRight()) {
			foeDistance = Math.sqrt(Math.pow(foe.getX() - owner.getX(), 2) + Math.pow(foe.getY() - owner.getY(), 2));
		} else if (owner.isFacingLeft()) {
			foeDistance = Math.sqrt(Math.pow(owner.getX() - foe.getX(), 2) + Math.pow(foe.getY() - owner.getY(), 2));
		}
	}
	else {
		ownerX = owner.getX();
		ownerHipY = owner.getY() + owner.getEcbRightHipY();
		foeX = foe.getX();
		foeHipY = foe.getY() + foe.getEcbRightHipY();

		if (owner.isFacingRight()) {
			foeDistance = Math.sqrt(Math.pow(foe.getX() - owner.getX(), 2) + Math.pow(foe.getY() - owner.getY(), 2));
		} else if (owner.isFacingLeft()) {
			foeDistance = Math.sqrt(Math.pow(owner.getX() - foe.getX(), 2) + Math.pow(foe.getY() - owner.getY(), 2));
		}
	}
}

function pull() {
	pullAngle = Math.getAngleBetween(fPos, oPos);
	pullStrength = (foeDistance - 300) * 0.5;
	if (pullStrength > 30) {
		pullStrength = 30;
	}

	pullXSpeed = Math.calculateXVelocity(pullStrength, pullAngle);
	pullYSpeed = Math.calculateYVelocity(-pullStrength, pullAngle);


	if (foe.getHitstun() > 0) {
		newPullXSpeed = foe.getXKnockback() + (pullXSpeed - foe.getXKnockback()) * 0.1;
		newPullYSpeed = foe.getYKnockback() + (pullYSpeed - foe.getYKnockback()) * 0.03;
	}
	else {
		newPullXSpeed = foe.getXKnockback() + (pullXSpeed - foe.getXKnockback()) * 0.3;
		newPullYSpeed = foe.getYKnockback() + (pullYSpeed - foe.getYKnockback()) * 0.3;
	}

	foe.setXKnockback(newPullXSpeed);
	foe.setYKnockback(newPullYSpeed);

	if (eyes.getAnimation() == "eyes_struggle") {
		squee -= 20;
	}
	else if (eyes.getAnimation() == "eyes_angry") {
		squee -= 10;
	}
	Engine.log(squee);

	if (squee < 0) {
		if (retracting == false) {
			if (retractTimer == 15) {
				AudioClip.play(self.getResource().getContent("pre_pull"));
				owner.forceStartHitstop(15);
				foe.forceStartHitstop(15, true);
				eyes.playAnimation("eyes_struggle");
				pupils.playFrame(2);
				eyesFront.playFrame(3);
				ropeShake = 59;
				retractTimer -= 1;
			}
			else if (retractTimer > 0) {
				retractTimer -= 1;
			}
			else {
				AudioClip.play(self.getResource().getContent("pull"));
				foe.setKnockback(20, pullAngle);
				camera.shake(3);
				retracting = true;
				pullAnchor = match.createVfx(new VfxStats({ spriteContent: self.getResource().getContent("lasso"), animation: "pull_anchor", loop: true, physics: true }), foe);
				pullAnchor.pause();
				pullAnchor.setX(foeX);
				pullAnchor.setY(foeHipY);

				foeSprites.left.destroy();
				foeSprites.right.destroy();
				for (sprite in foeSprites.center) {
					sprite.destroy();
				}
			}
		}
	}
	else if (squee < 500 && !flashed) {
		flash();
		flashTimer = self.addTimer(20, 0, function () {
			flash();
		}, { persistent: true });
		flashed = true;
	}
}

function buildRope() {
	var distance = calculateDistance();
	var numberOfSegments = distance > 0 ? Math.max(1, Math.floor(distance / ropeSegmentLength)) : 0;
	var angleDegrees = calculateCurrentAngle();

	for (i in 0...numberOfSegments) {
		var segmentPosition = calculateRopePosition(i, angleDegrees);
		createRopeSprite(segmentPosition.x, segmentPosition.y, angleDegrees);
	}
}

function buildWrap(character: Character) {
	var characterCenterX = character.getX();
	var hipY = character.getY() + character.getEcbLeftHipY();

	var leftHipX = character.getX() + character.getEcbLeftHipX();
	var rightHipX = character.getX() + character.getEcbRightHipX();

	var totalRopeWidth = 2 * edgeSpriteWidth + ropeSegmentWidth;
	var availableWidth = rightHipX - leftHipX - 2 * edgeSpriteWidth;
	var numberOfCenterSegments = Math.max(1, Math.floor(availableWidth / ropeSegmentWidth));

	var totalWidth = 2 * edgeSpriteWidth + numberOfCenterSegments * ropeSegmentWidth;
	var startingX = characterCenterX - totalWidth / 2;


	var leftSprite = Sprite.create(self.getResource().getContent("lasso"));
	leftSprite.currentAnimation = "left";
	leftSprite.x = startingX;
	leftSprite.y = hipY;
	leftSprite.addShader(self.getCostumeShader());
	stage.getCharactersFrontContainer().addChild(leftSprite);


	var centerSprites = [];
	for (i in 0...numberOfCenterSegments) {
		var centerSpriteX = startingX + edgeSpriteWidth + i * ropeSegmentWidth;
		var centerSprite = Sprite.create(self.getResource().getContent("lasso"));
		centerSprite.currentAnimation = "center";
		centerSprite.x = centerSpriteX;
		centerSprite.y = hipY;
		centerSprite.addShader(self.getCostumeShader());
		stage.getCharactersFrontContainer().addChild(centerSprite);
		centerSprites.push(centerSprite);
	}


	var rightSpriteX = startingX + edgeSpriteWidth + numberOfCenterSegments * ropeSegmentWidth;
	var rightSprite = Sprite.create(self.getResource().getContent("lasso"));
	rightSprite.currentAnimation = "right";
	rightSprite.x = rightSpriteX;
	rightSprite.y = hipY;
	rightSprite.addShader(self.getCostumeShader());
	stage.getCharactersFrontContainer().addChild(rightSprite);

	return { left: leftSprite, center: centerSprites, right: rightSprite };
}




function calculateDistance(): Float {
	return Math.sqrt(Math.pow(foeX - ownerX, 2) + Math.pow(foeHipY - ownerHipY, 2));
}

function calculateCurrentAngle(): Float {
	var angleRadians = Math.atan2(foeHipY - ownerHipY, foeX - ownerX);
	return angleRadians * (180 / Math.PI);
}

function calculateRopePosition(segmentIndex: Int, angleDegrees: Float): { x: Float, y: Float } {
	var distance = segmentIndex * ropeSegmentLength;
	var angleRadians = angleDegrees * (Math.PI / 180);

	var x = ownerX + Math.cos(angleRadians) * distance;
	var y = ownerHipY + Math.sin(angleRadians) * distance;
	return { x: x, y: y };
}

function createRopeSprite(x: Float, y: Float, rotation: Float) {
	var rope = Sprite.create(self.getResource().getContent("lasso"));
	rope.currentAnimation = "rope";
	rope.x = x;
	rope.y = y;
	rope.rotation = rotation;
	rope.addShader(self.getCostumeShader());
	if (isFlashing) {
		var filter = new HsbcColorFilter();
		var brightness = .5;
		filter.brightness = brightness;
		rope.addFilter(filter);
		self.addTimer(flashFrames, 1, function () {
			rope.removeFilter(filter);
		}, { persistent: true });
	}
	ropeSprites.push(rope);
	stage.getCharactersBackContainer().addChild(rope);
}

function updateWrapPositions(character, spriteGroup) {
	var characterCenterX = character.getX();
	var hipY = character.getY() + character.getEcbLeftHipY();


	var totalWidth = 2 * edgeSpriteWidth + spriteGroup.center.length * ropeSegmentWidth;
	var startingX = characterCenterX - totalWidth / 2;


	spriteGroup.left.x = startingX;
	spriteGroup.left.y = hipY;


	var currentX = startingX + edgeSpriteWidth;
	for (i in 0...spriteGroup.center.length) {
		spriteGroup.center[i].x = currentX;
		spriteGroup.center[i].y = hipY;
		currentX += ropeSegmentWidth;
	}

	if (spriteGroup.center.length > 0) {
		spriteGroup.right.x = currentX;
	} else {
		spriteGroup.right.x = startingX + edgeSpriteWidth;
	}
	spriteGroup.right.y = hipY;
}


function ropeStartAnim() {
	ropeFrame = 1;
	self.addTimer(1, 10, function () {
		ropeFrame += 1;
	});
	self.addTimer(11, 1, function () {
		ropeStartAnimFinished = true;
	});
}

function update() {
	if (self.getCostumeIndex() == 5 || self.getCostumeIndex() == 4) goldAltLogic();

	self.setX(owner.getX());
	self.setY(owner.getY() + owner.getEcbLeftHipY());

	if (retracting == true) {
		if (flashTimer != null) self.removeTimer(flashTimer);
		fPos = Point.create(pullAnchor.getX(), pullAnchor.getY());
		oPos = Point.create(owner.getX(), owner.getY() + owner.getEcbLeftHipY());
		actualFPos = Point.create(foe.getX(), foe.getY() + foe.getEcbLeftHipY());

		if (eyes.getAnimation() != "eyes_tired2") {
			eyes.playAnimation("eyes_tired2");
			pupils.playFrame(3);
			eyesFront.playFrame(4);
		}

		if (owner.isFacingRight()) {
			foeDistance = Math.sqrt(Math.pow(pullAnchor.getX() - owner.getX(), 2) + Math.pow(pullAnchor.getY() - ownerHipY, 2));
		} else if (owner.isFacingLeft()) {
			foeDistance = Math.sqrt(Math.pow(owner.getX() - pullAnchor.getX(), 2) + Math.pow(pullAnchor.getY() - ownerHipY, 2));
		}
		if (foeDistance < retractSpeed * 2) {
			ending = true;
			self.destroy();
		}

		if (ending == false) {
			upatePositions();

			pullAnchor.setXVelocity(Math.calculateXVelocity(retractSpeed, Math.getAngleBetween(fPos, oPos)));
			pullAnchor.setYVelocity(Math.calculateYVelocity(-retractSpeed, Math.getAngleBetween(fPos, oPos)));
			retractSpeed = retractSpeed * 1.05;

			eyes.setX((foeX + ownerX) / 2);
			eyes.setY((foeHipY + ownerHipY) / 2);

			lookPoint = Point.create(eyes.getX(), eyes.getY() - 5);
			lookAngle = Math.getAngleBetween(lookPoint, actualFPos);

			pupils.setX(eyes.getX() + Math.calculateXVelocity(2, lookAngle));
			if (Math.calculateYVelocity(2, lookAngle) < -1) {
				pupils.setY(eyes.getY() - Math.calculateYVelocity(2, lookAngle));
			}
			else {
				pupils.setY(eyes.getY());
			}
			eyesFront.setX(eyes.getX());
			eyesFront.setY(eyes.getY());

			knotBall.setX(ownerX);
			knotBall.setY(ownerHipY);

			var angleDegrees = calculateCurrentAngle();
			var currentDistance = calculateDistance();
			var requiredSegments = Math.max(1, Math.floor(currentDistance / ropeSegmentLength));
			var currentSegments = ropeSprites.length;
			if (requiredSegments > currentSegments) {
				for (i in currentSegments...requiredSegments) {
					createRopeSprite(0, 0, 0);
				}
			} else if (requiredSegments < currentSegments) {
				for (i in requiredSegments...currentSegments) {
					var spriteToRemove = ropeSprites.pop();
					stage.getCharactersBackContainer().removeChild(spriteToRemove);
					spriteToRemove.kill();
				}
			}
			for (i in 0...ropeSprites.length) {
				var segmentPosition = calculateRopePosition(i, angleDegrees);
				var sprite: Sprite = ropeSprites[i];
				sprite.x = segmentPosition.x;
				sprite.y = segmentPosition.y;
				sprite.rotation = angleDegrees;
				if (ropeStartAnimFinished == true) {
					sprite.currentFrame = 12;
				}
				else {
					sprite.currentFrame = ropeFrame;
				}
				if (owner.getX() > foe.getX()) sprite.scaleY = -1;
				else {
					sprite.scaleY = 1;
				}
			}
			if (ropeSprites[(ropeSprites.length - 1)].currentAnimation != "retract") {
				ropeSprites[(ropeSprites.length - 1)].currentAnimation = "retract";
				ropeSprites[(ropeSprites.length - 1)].advance();
			}
		}
	}
	else {
		if (foe != null) {
			if (foe.getAnimation() == "hurt_heavy") {
				foe.playAnimation("hurt_medium");
			}
			if (self.getOwner().getState() == CState.KO || self.getOwner().getY() > stage.getCameraBounds().getY() + stage.getCameraBounds().getRectangle().height) {
				AudioClip.play(self.getResource().getContent("pull"));
				foe.takeHit(new HitboxStats({ damage: 0, angle: 90, baseKnockback: 20, knockbackGrowth: 0, hitstop: 0, selfHitstop: 0, hitstun: 1, reversibleAngle: false, hitSoundOverride: "#n/a", hitEffectOverride: "#n/a", tumbleType: TumbleType.ALWAYS }));
				retracting = true;
				pullAnchor = match.createVfx(new VfxStats({ spriteContent: self.getResource().getContent("lasso"), animation: "pull_anchor", loop: true, physics: true }), foe);
				pullAnchor.pause();
				pullAnchor.setX(foeX);
				pullAnchor.setY(foeHipY);
				foeSprites.left.destroy();
				foeSprites.right.destroy();
				for (sprite in foeSprites.center) {
					sprite.destroy();
				}
			}
			else if (foe.getState() == CState.KO) {
				AudioClip.play(self.getResource().getContent("pull"));
				retracting = true;
				pullAnchor = match.createVfx(new VfxStats({ spriteContent: self.getResource().getContent("lasso"), animation: "pull_anchor", loop: true, physics: true }), foe);
				pullAnchor.pause();
				pullAnchor.setX(foeX);
				pullAnchor.setY(foeHipY);
				foeSprites.left.destroy();
				foeSprites.right.destroy();
				for (sprite in foeSprites.center) {
					sprite.destroy();
				}
			}
			fPos = Point.create(foe.getX(), foe.getY() + foe.getEcbLeftHipY());
			oPos = Point.create(owner.getX(), owner.getY() + owner.getEcbLeftHipY());
			if (eyes != null) {
				eyes.setX((foeX + ownerX) / 2);
				eyes.setY((foeHipY + ownerHipY) / 2);

				lookPoint = Point.create(eyes.getX(), eyes.getY() - 5);
				lookAngle = Math.getAngleBetween(lookPoint, fPos);

				pupils.setX(eyes.getX() + Math.calculateXVelocity(2, lookAngle));
				if (Math.calculateYVelocity(2, lookAngle) < -1) {
					pupils.setY(eyes.getY() - Math.calculateYVelocity(2, lookAngle));
				}
				else {
					pupils.setY(eyes.getY());
				}
				eyesFront.setX(eyes.getX());
				eyesFront.setY(eyes.getY());

				knotBall.setX(ownerX);
				knotBall.setY(ownerHipY);
			}
			upatePositions();
			updateWrapPositions(foe, foeSprites);

			if (foeDistance >= 310) {
				pull();
				if (retractTimer == 15 || retractTimer == 0) {
					if (foeDistance >= 370) {
						ropeShake = 59;
					}
					else if (foeDistance >= 340) {
						ropeShake = 40;
						eyes.playAnimation("eyes_struggle");
						pupils.playFrame(2);
						eyesFront.playFrame(3);

						if (stretchSound != null) {
							if (stretchSound.isPlaying()) {
								stretchSound.stop();
							}
						}
						stretchSound = AudioClip.play(self.getResource().getContent(Random.getChoice([
							"stretch1", "stretch2", "stretch3", "stretch4", "stretch5", "stretch6", "stretch7", "stretch8"
						])));
					}
					else {
						ropeShake = 21;
						if (eyes.getAnimation() != "eyes_struggle") {
							eyes.playAnimation("eyes_angry");
							pupils.playFrame(1);
							eyesFront.playFrame(2);

							if (stretchSound != null) {
								if (stretchSound.isPlaying()) {
									stretchSound.stop();
								}
							}
							stretchSound = AudioClip.play(self.getResource().getContent(Random.getChoice([
								"stretch1", "stretch2", "stretch3", "stretch4", "stretch5", "stretch6", "stretch7", "stretch8"
							])));
						}
					}
				}
			}
			else {
				if (stretchSound != null) {
					if (stretchSound.isPlaying()) {
						stretchSound.stop();
					}
				}
				if (retractTimer == 15 || retractTimer == 0) {
					ropeShake = 11;
					if (eyes.getAnimation() == "eyes_struggle") {
						eyes.playAnimation("eyes_tired");
						pupils.playFrame(3);
						eyesFront.playFrame(4);
					}
					else if (eyes.getAnimation() != "eyes_tired") {
						eyes.playAnimation("eyes_neutral");
						pupils.playFrame(1);
						eyesFront.playFrame(1);
					}
				}
			}

			var angleDegrees = calculateCurrentAngle();
			var currentDistance = calculateDistance();
			var requiredSegments = Math.max(1, Math.floor(currentDistance / ropeSegmentLength));
			var currentSegments = ropeSprites.length;

			if (requiredSegments > currentSegments) {

				for (i in currentSegments...requiredSegments) {
					createRopeSprite(0, 0, 0);
				}
			} else if (requiredSegments < currentSegments) {

				for (i in requiredSegments...currentSegments) {
					var spriteToRemove = ropeSprites.pop();
					stage.getCharactersBackContainer().removeChild(spriteToRemove);
					spriteToRemove.kill();
				}
			}

			for (i in 0...ropeSprites.length) {
				var segmentPosition = calculateRopePosition(i, angleDegrees);
				var sprite: Sprite = ropeSprites[i];
				sprite.x = segmentPosition.x;
				sprite.y = segmentPosition.y;
				sprite.rotation = angleDegrees;
				if (ropeStartAnimFinished == true) {
					sprite.currentFrame = ropeShake + ropeFrame;
				}
				else {
					sprite.currentFrame = ropeFrame;
				}

				if (owner.getX() > foe.getX()) sprite.scaleY = -1;
				else {
					sprite.scaleY = 1;
				}

			}
			if (ropeStartAnimFinished == true) {
				ropeFrame += 1;
				if (ropeFrame > 8) {
					ropeFrame = 0;
				}
			}
		}
	}
}

function onTeardown() {
	if (knotBall != null) {
		knotBall.destroy();
	}
	if (eyes != null) {
		eyes.destroy();
	}
	if (eyesFront != null) {
		eyesFront.destroy();
	}
	if (pupils != null) {
		pupils.destroy();
	}
	if (pullAnchor != null) {
		pullAnchor.destroy();
	}
	for (i in 0...ropeSprites.length) {
		var sprite = ropeSprites.pop();
		sprite.kill();
	}
}