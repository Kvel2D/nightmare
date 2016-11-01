import haxegon.*;

typedef Vec2 = {
    x: Float,
    y: Float,
}
typedef Cog = {
    x: Float,
    y: Float,
    screenX: Float,
    screenY: Float,
    angle: Float,
    direction: Int,
    health: Int,
}

class Main {
    var degToRad = Math.PI / 180;
    var tmpVec2 = {x:0.0, y:0.0};
    var tmpVec2i = {x:0.0, y:0.0};
    var cogs: Array<Cog>;
    var cogSpeed = 0.0;
    var cogRadius = 38 / 2;
    var recoverTimer = 0;
    var height = 0.0;

    var robotPos: Vec2;
    var robotAngle = 0.0;
    var robotAngleMax = 15.0;
    var robotWidth: Float;
    var robotHeight: Float;
    var robotColor = Col.makeColor(76, 67, 153);
    var jawCounter = 0;
    var jawAngle = 0.0;
    var jawHeightMin = 40.0;
    var jawHeightMax = -60.0;
    var jawHeight = 40.0;

    var cogColor4 = Col.YELLOW;
    var cogColor3 = Col.makeColor(222, 144, 51);
    var cogColor2 = Col.ORANGE;
    var cogColor1 = Col.RED;

    function new() {
        Gfx.lineThickness = 9;
        Gfx.resizeScreen(500, 300);
        Gfx.loadImage("cog");
        Gfx.loadImage("robot");
        Gfx.loadImage("robot_back");
        Gfx.loadImage("robot_stuff");
        Gfx.loadImage("jaw_left");
        Gfx.loadImage("jaw_right");
        Gfx.loadImage("background");
        Gfx.loadImage("tear");

        robotWidth = Gfx.imageWidth("robot");
        robotHeight = Gfx.imageHeight("robot");
        robotPos = {x:Gfx.screenWidth / 2 - robotWidth / 2, y: Gfx.screenHeight / 16};

        cogs = new Array<Cog>();
        var positions: Array<Vec2> = [for (i in 0...7) ({x:0.0, y:0.0})];
        var deg60 = Math.PI / 3;
        var deg45 = Math.PI / 4;
        var deg30 = Math.PI / 6;
        var deg15 = Math.PI / 12;
        positions[0].x = 50;
        positions[0].y = 85;
        positions[1].x = positions[0].x + 1.9 * cogRadius * Math.cos(deg45);
        positions[1].y = positions[0].y - 1.9 * cogRadius * Math.sin(deg45);
        positions[2].x = positions[1].x - 1.9 * cogRadius * Math.cos(deg45);
        positions[2].y = positions[1].y - 1.9 * cogRadius * Math.sin(deg45);
        positions[3].x = positions[2].x - 1.9 * cogRadius * Math.cos(deg45);
        positions[3].y = positions[2].y + 1.9 * cogRadius * Math.sin(deg45);

        positions[4].x = positions[0].x - 1.9 * cogRadius * Math.cos(deg30);
        positions[4].y = positions[0].y + 1.9 * cogRadius * Math.sin(deg30);
        positions[5].x = positions[4].x + 1.9 * cogRadius * Math.cos(deg60);
        positions[5].y = positions[4].y + 1.9 * cogRadius * Math.sin(deg60);
        positions[6].x = positions[5].x + 1.9 * cogRadius * Math.cos(deg15);
        positions[6].y = positions[5].y - 1.9 * cogRadius * Math.sin(deg15);

        var cogDir = 1;
        var cogAngle = 0.0;
        for (pos in positions) {
            cogs.push({
                x: pos.x,
                y: pos.y,
                screenX: 0.0,
                screenY: 0.0,
                angle: cogAngle,
                direction: cogDir,
                health: 10
            });
            cogDir = -cogDir;
            if (cogAngle > 0) {
                cogAngle = 0;
            } else {
                cogAngle = 5;
            }
        }
    }

    function rotateAround(position: Vec2, xOrigin: Float, yOrigin: Float, angle: Float) {
        var angleConverted = angle / 57.2958;

        var cos = Math.cos(angleConverted);
        var sin = Math.sin(angleConverted);

        position.x -= xOrigin;
        position.y -= yOrigin;
        var xTemp = position.x;
        var yTemp = position.y;
        position.x = xTemp * cos - yTemp * sin;
        position.y = xTemp * sin + yTemp * cos;
        position.x += xOrigin;
        position.y += yOrigin;
    }

    function update() {
        for (cog in cogs) {
            tmpVec2.x = cog.x + cogRadius;
            tmpVec2.y = cog.y + cogRadius;
            rotateAround(tmpVec2, robotWidth / 2, robotHeight / 2, robotAngle);
            cog.screenX = tmpVec2.x + robotPos.x - cogRadius;
            cog.screenY = tmpVec2.y + robotPos.y - cogRadius;
        }

        if (Mouse.leftclick()) {
            var closestCog = cogs[0];
            var closestDistance = MathUtils.dst2(Mouse.x, Mouse.y, cogs[0].screenX + cogRadius, cogs[0].screenY + cogRadius);
            for (cog in cogs) {
                var distance = MathUtils.dst2(Mouse.x, Mouse.y, cog.screenX + cogRadius, cog.screenY + cogRadius);
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closestCog = cog;
                }
            }
            if (closestDistance < cogRadius * cogRadius) {
                closestCog.health--;
                if (closestCog.health <= 0) {
                    cogs.remove(closestCog);
                } else {
                    cogSpeed += 0.1;
                }
            }
        }

        cogSpeed *= 0.995;
        if (jawHeight != jawHeightMax) {
            height += cogSpeed;
            if (height < 400) {
                jawHeight -= 0.3 - cogSpeed;
            } else {
                jawHeight -= 1.5 - cogSpeed;
            }
        }

        if (jawHeight > jawHeightMin) {
            jawHeight = jawHeightMin;
        } else if (jawHeight < jawHeightMax) {
            jawHeight = jawHeightMax;
        }

        recoverTimer++;
        if (recoverTimer > 2 * 60) {
            recoverTimer = 0;
            for (cog in cogs) {
                if (cog.health < 10) {
                    cog.health++;
                }
            }
        }

        if (jawHeight != jawHeightMax) {
            jawCounter++;
        } else if (jawAngle < 34) {
            jawCounter++;
        }
        jawAngle = 35 * Math.sin(jawCounter / 10);
        if (jawHeight != jawHeightMax) {
            robotAngle = robotAngleMax * Math.sin(height / 100);
        }

        Gfx.rotation(0);
        Gfx.drawImage(0, height % Gfx.screenHeight, "background");
        Gfx.drawImage(0, height % Gfx.screenHeight - Gfx.screenHeight - 1, "background");
        Gfx.fillBox(0, 0, Gfx.screenWidth / 4, Gfx.screenHeight, Col.DARKBLUE);
        Gfx.fillBox(Gfx.screenWidth * 3 / 4, 0, Gfx.screenWidth / 4, Gfx.screenHeight, Col.DARKBLUE);


        Gfx.rotation(robotAngle);
        Gfx.drawImage(robotPos.x, robotPos.y, "robot_back");
        Gfx.drawImage(robotPos.x, robotPos.y, "robot");
        Gfx.drawImage(robotPos.x - 30, robotPos.y - 30, "robot_stuff");

        for (cog in cogs) {
            cog.angle += cog.direction * cogSpeed;
            if (cog.angle > 360) {
                cog.angle = 0;
            }

            Gfx.rotation(cog.angle + robotAngle);
            Gfx.drawImage(cog.screenX, cog.screenY, "cog");
            if (cog.health < 2){
                Gfx.fillCircle(cog.screenX + cogRadius, cog.screenY + cogRadius, cogRadius * 0.85,
                    cogColor1, 0.7);
            } else if (cog.health < 3){
                Gfx.fillCircle(cog.screenX + cogRadius, cog.screenY + cogRadius, cogRadius * 0.85,
                    cogColor2, 0.7);
            } else if (cog.health < 4){
                Gfx.fillCircle(cog.screenX + cogRadius, cog.screenY + cogRadius, cogRadius * 0.85,
                    cogColor3, 0.7);
            } else if (cog.health < 6){
                Gfx.fillCircle(cog.screenX + cogRadius, cog.screenY + cogRadius, cogRadius * 0.85,
                    cogColor4, 0.7);
            }
        }

        var legLength = (robotPos.x - Gfx.screenWidth / 4) / 2 * 1.4;
        var kneeAngleMultiplier = 3;
        var feetAngleMultiplier = 2 / 3;

        tmpVec2.x = robotPos.x + 5;
        tmpVec2.y = robotPos.y + robotHeight - 5;
        rotateAround(tmpVec2, robotPos.x + robotWidth / 2, robotPos.y + robotHeight / 2, robotAngle);
        var hipX = tmpVec2.x;
        var hipY = tmpVec2.y;
        var kneeX = tmpVec2.x - legLength * Math.cos(-(robotAngle + robotAngleMax) * degToRad * kneeAngleMultiplier);
        var kneeY = tmpVec2.y + legLength * Math.sin(-(robotAngle + robotAngleMax) * degToRad * kneeAngleMultiplier);
        Gfx.drawLine(tmpVec2.x, tmpVec2.y, kneeX, kneeY, robotColor);
        var feetX = kneeX - legLength * Math.cos(-robotAngle * degToRad * feetAngleMultiplier);
        var feetY = kneeY + legLength * Math.sin(-robotAngle * degToRad * feetAngleMultiplier);
        Gfx.drawLine(kneeX, kneeY, feetX, feetY, robotColor);

        Gfx.drawLine(feetX, feetY - 20, feetX, feetY + 10, robotColor);

        tmpVec2.x = robotPos.x + robotWidth - 5;
        tmpVec2.y = robotPos.y + robotHeight - 5;
        rotateAround(tmpVec2, robotPos.x + robotWidth / 2, robotPos.y + robotHeight / 2, robotAngle);
        hipX = tmpVec2.x;
        hipY = tmpVec2.y;
        kneeX = tmpVec2.x + legLength * Math.cos((robotAngle - robotAngleMax) * degToRad * kneeAngleMultiplier);
        kneeY = tmpVec2.y + legLength * Math.sin((robotAngle - robotAngleMax) * degToRad * kneeAngleMultiplier);
        Gfx.drawLine(tmpVec2.x, tmpVec2.y, kneeX, kneeY, robotColor);
        feetX = kneeX + legLength * Math.cos(robotAngle * degToRad * feetAngleMultiplier);
        feetY = kneeY + legLength * Math.sin(robotAngle * degToRad * feetAngleMultiplier);
        Gfx.drawLine(kneeX, kneeY, feetX, feetY, robotColor);

        Gfx.drawLine(feetX, feetY - 20, feetX, feetY + 10, robotColor);

        Gfx.rotation(jawAngle);
        Gfx.drawImage(Gfx.screenWidth / 4 + 50, Gfx.screenHeight * 7 / 8 + jawHeight, "jaw_left");
        Gfx.rotation(-jawAngle);
        Gfx.drawImage(Gfx.screenWidth * 3 / 4 - 153, Gfx.screenHeight * 7 / 8 + jawHeight, "jaw_right");

        if (jawHeight == jawHeightMax && jawAngle > 34) {
            tmpVec2.x = robotPos.x + 105;
            tmpVec2.y = robotPos.y + 30;
            rotateAround(tmpVec2, robotPos.x + robotWidth / 2, robotPos.y + robotHeight / 2, robotAngle);
            Gfx.rotation(0);
            Gfx.drawImage(tmpVec2.x, tmpVec2.y, "tear");
        } 
    }
}