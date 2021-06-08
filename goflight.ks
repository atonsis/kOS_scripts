//Go Flight

parameter desiredInclination.
parameter desiredApoapsis.
parameter flightAt.

start().

function start {  
    set pitchStartingAlt to 250.
    set halfPitchedAlt to 12000.
    set tLimitAlt to 20000.
    set thrustAdj to 0.9.
    set finalThrustAdj to 0.9.
    set lockAlt to 70000.
    set fairingAlt to 50000.
    set deployAlt to 70000.
    set thrustSetting to 1.
    set thrustLimiter to 1.
    set deployed to false.
    set progradeLock to false.
    set thrustLimited to false.
    set upperLimited to false.
    set abort to false.
    set fairingStaged to false.
    set vPitch to 90.
    set vHeading to 0.
    print " ".
    print "Peform Pre-Flight Checks? (Y) or (N): ".
    set preFlightQuery to terminal:input:getchar().
        if (preFlightQuery = "Y") { 
            global verb to 1.
            main().
        } else if (preFlightQuery = "N"){
            global verb to 3.
            main().
        } else {
            print "Input not recognized. Ending program.".
            global verb to 0.
            main().
        }
    }

function main {
    if (verb = 1) {
        wait 2.
        clearscreen.
        setAbortTrigger().
        systemCheck().
        gimbalCheck().
        if abort = false {
            set oldThrust to availableThrust.
            pitchManeuver().
        }
        if abort = false  {
            gravityTurn().
            autoStage().
        }
        if abort = false  {
            meco().
            circNode().
            exeMnv().
        }
    }
    if (verb = 3){
        launchCheck().
        if abort = false {
            set oldThrust to availableThrust.
            pitchManeuver().
        }
        if abort = false  {
            gravityTurn().
            autoStage().
        }
        if abort = false  {
            meco().
            circNode().
            exeMnv().
        }
    }
    }
    if (verb = 0) {
        lock throttle to 0.
        kill().
    }
    
function myPitch {
    return 90*halfPitchedAlt / (altitude + halfPitchedAlt).
}
function myRoll {
    if (flightAt = "i") {
        set tempRoll to 270 - myHeading.
    } else if (flightAt = "n") {
        set tempRoll to 90-myHeading.
    } else {
        set tempRoll to 360-myHeading.
    }
    return tempRoll.
}
function myHeading {
    set roughHeading to (90 - desiredInclination).
    if (roughHeading < 0) {
        set roughHeading to (360 + roughHeading).
    }
    set triAng to abs(90 - roughHeading).
    set vH to sqrt(1774800 - 475200*cos(triAng)).
    set correction to arcsin(180*sin(triAng) / vH).
    if (desiredInclination > 0) {
        set correction to -1*correction.
    }
    if ((roughHeading + correction) < 0) {
        return roughHeading + correction + 360.
    } else {
        return roughHeading + correction.
    }
}
function systemCheck {
    if (verb = 1) {
        list resources in resList.
        print " ".
        print "Begining Pre-Launch Checks...".
        wait 2.
        print " ".
        print "Range is Green.".
        powerCheck(resList).
        wait 2.
        propLoad(resList).
        wait 2.
        lifeSupport(reslist).
        wait 2.
        crewCheck().
        wait 2.
        global verb to 2.
    }
}
function powerCheck {
    parameter resList.
    print " ".
    print "Power Checks: ".
    for resource in resList{
        if (resource:name = "electriccharge"){
            print " ".
            print "Electric Charge: " + round(resource:amount) + " Coulombs".
            print "Electric Charge: " + round((resource:amount)*9 / (10^6), 8)  + " MegaJoules".
            wait 3.
            print " ".
            print "        Electric Charge is GO.".
        }
    }
    print " ".
    print "Power Checks complete.".
}
function propLoad {
    parameter resList.
    print " ".
    print "Propellant Load: ".
    for resource in resList{
        if (resource:name = "liquidfuel"){
           print " ".
           print "Liquid Fuel: " +round(resource:amount / 5) + " kilograms".
           print " ".
           print "        Liquid Fuel is GO.".
           wait 2.
        }
        if (resource:name = "oxidizer"){
            print " ".
            print "Oxidizer: " +round(resource:amount / 5) + " kilograms".
            print " ".
            print "        Oxidizer is GO.".
            wait 2.
        }
        if (resource:name = "monopropellant"){
            print " ".
            print "Monopropellant: " + round(resource:amount / 4) + " kilograms".
            print " ".
            print "        Monopropellant is GO.".
            wait 2.
        }
        if (resource:name = "solidfuel"){
            print " ".
            print "Solid Fuel: " + round(resource:amount / 7.5) + " kilograms".
            print " ".
            print "        Solid Fuel is GO.".
            wait 2.
        }
        if (resource:name = "xenongas"){
            print " ".
            print "Xenon Gas: " + round(resource:amount * 0.1)  + " kilograms".
            print " ".
            print "        Xenon Gas is GO.".
            wait 2.
        }  
    }
    print " ".
    print "Propellant Load Checks Complete.".
    wait 1.
    print " ".
    print "        Propellant is GO.".
}
function lifeSupport {
    parameter resList.
    print " ".
    print "Life Support System: ".
    for resource in resList {
        if (resource:name = "food"){
            print " ".
            print "Food: " + round(resource:amount * 0.25)  + " kilograms".
            print " ".
            print "        Food is GO.".
            wait 2.
        }
        if (resource:name = "water"){
            print " ".
            print "Water: " + round(resource:amount)  + " kilograms".
            print " ".
            print "        Water is GO.".
            wait 2.
        }
        if (resource:name = "oxygen"){
            print " ".
            print "Oxygen: " + round((resource:amount)*0.00157) + " kilograms".
            print " ".
            print "        Oxygen is GO.".
            wait 2.
        }
        if (resource:name = "nitrogen"){
            print " ".
            print "Nitrogen: " + round(resource:amount * 0.00125)  + " kilograms".
            print " ".
            print "        Nitrogen is GO.".
            wait 2.
        }     
    }
    print " ".
    print "Life Support Checks Complete.".
    wait 1.
    print " ".
    print "        Life Support is GO".
}
function crewCheck {
    print " ".
    print "Beginning Crew Check.".
    if ship:crew:length > 0 {
        local crewlist is ship:crew.
        print " ".
        print crewList.
        print " ".
        wait 2.
        print "        Crew is GO.".
    } else {
        wait 2.
        print " ".
        print "No crew onboard.".
        wait 1.
        print " ".
        print "        Probe Control is GO.".
    }
}
function gimbalCheck {
    if (verb = 2) {
        wait 1.
        print " ".
        print "Gimbal Swing in progress...".
        lock throttle to 0.
        wait 1.
        set ship:control:pitch to 1.
        wait 1.
        set ship:control:pitch to -1.
        wait 1.
        set ship:control:pitch to 0.
        wait 1.
        set ship:control:yaw to 1.
        wait 1.
        set ship:control:yaw to -1.
        wait 1.
        set ship:control:yaw to 0.
        wait 1.
        set ship:control:roll to 1.
        wait 1.
        set ship:control:roll to -1.
        wait 1.
        set ship:control:roll to 0.
        wait 1.
        print " ".
        print "Gimbal Check Complete.".
        global verb to 3.
        launchCheck().
    }
}
function launchCheck {
    if (verb = 3) {
        print " ".
        print "LD is GO For Flight".
        wait 3.
        countdown().
        }
}
function countdown {
    SAS off.
    wait 2.
    clearScreen.
    wait 2.
    print " ".
    print "Entering Terminal Count.".
    wait 1.
    print "T-00:15.".
    wait 5.
    print "T-00:10".
    wait 1.
    print "T-00:09".
    wait 1.
    print "T-00:08".
    wait 1.
    print "T-00:07".
    wait 1.
    print "T-00:06".
    wait 1.
    print "T-00:05".
    wait 1.
    print "T-00:04".
    wait 1.
    lock throttle to 1.
    print "Main Engine Start.".
    stage.
    wait 1.
    if (SHIP:AVAILABLETHRUSTAT(1.0) < 1.15*(MASS-clampMass())*CONSTANT:g0) {
        print " ".
        print "Subnominal Thrust Detected.".
        print "Attempting Shutdown.".
        lock throttle to 0.
        set abort to true.
        global verb to 0. 
    } else {
            set abort to false.
            wait .5.
            print "T-00:02".
            wait 1.
            print "T-00:01".
            wait 1.
            stage.
            print " ".
            print "Liftoff.".
            global verb to 4.
            clearScreen.
     }
}
function setAbortTrigger {
   on abort {
       if abort = false {
           lock throttle to 0.
           abort on.
           print " ".
           print "Abort has been triggered manually.".
           print " ".
           print "Aborting.".
           set abort to true.
           global verb to 0.
       }
   }
}
function autoAbort {
    if (altitude < tLimitAlt){
        lock throttle to 0.
        abort on.
    }
    print " ".
    print "Attitude control loss detected.".
    print "Aborting.".
    set abort to true.
    global verb to 0.
    
}
function pitchManeuver {
    lock vPitch to 90 - vAng(up:forevector, facing:forevector).
    lock vHeading to mod(360 - latlng(90, 0):bearing, 360).
    until (altitude > pitchStartingAlt){
        if abs(vPitch-myPitch())>10 and abort = 0 {
            autoAbort().
            break.
        }
        wait 0.1.
    }
    print " ".
    print "Pitching Downrange.".
    set initialHeading to myHeading().
    set initialRoll to myRoll().
    print " ".
    print "Roll Program.".
    lock steering to heading(initialHeading, myPitch())+ r(0, 0, initialRoll).
    wait 2.
}
function lockToPrograde {
    print " ".
    print "Locking to Prograde.".
    lock steering to prograde + r(0, 0, myRoll()).
    set progradeLock to true.
}
function shipTWR {
    return availableThrust*thrustSetting / (mass*constant:g0).
}
function autoStage {
    PARAMETER enableStage IS TRUE.
    LOCAL needStage IS FALSE.
    IF enableStage AND STAGE:READY {
        IF MAXTHRUST = 0 {
            SET needStage TO TRUE.
        } ELSE {
            LOCAL engineList IS LIST().
            LIST ENGINES IN engineList.
            FOR engine IN engineList {
                IF engine:IGNITION AND engine:FLAMEOUT {
                    SET needStage TO TRUE.
                    BREAK.
                }
            }
        }
        IF needStage    {
            STAGE.
            STEERINGMANAGER:RESETPIDS().
            print " ".
            PRINT "Staged".
        }
    } ELSE {
        SET needStage TO TRUE.
    }
    RETURN needStage.
}
function limitThrust {
    lock Fg to (body:mu/(body:radius+altitude)^2)*mass.
    if (availableThrust > 0) {
        if not thrustLimited {
            set thrustSetting to thrustAdj*Fg / (availableThrust+0.001).
            print " ".
            print "Adjusting TWR to " + thrustAdj.
        } else {
            set thrustSetting to finalThrustAdj*Fg / (availableThrust+0.001).
            print " ".
            print "Adjusting TWR to " + finalThrustAdj.
         }
         lock throttle to thrustSetting.
        if thrustLimited {
            set upperLimited to true.
        }
        set thrustLimited to true.
    } else {
        stage.
        wait 0.1.
    }
}
function meco {
    lock throttle to 0.
    print " ".
    print "MECO.".
    wait until altitude > lockAlt.
    if progradeLock = false {
        lockToPrograde().
    }
    wait until altitude > deployAlt.
    if deployed = false {
        autoDeploy().
    }
}
function gravityTurn {
    until (apoapsis > desiredApoapsis*1000) {
        autoStage().
        if (altitude > lockAlt) and not progradeLock {
            lockToPrograde().
        }
        if (altitude > tLimitAlt) and not thrustLimited {
            limitThrust().
        }
        if (shipTWR() < thrustAdj - 0.1) and thrustLimited and not upperLimited {
            limitThrust().
        }
        if (altitude > deployAlt) and not deployed {
            autoDeploy ().
        }
        if (altitude > fairingAlt) and not fairingStaged {
            autoFairing().
        }
        if (desiredInclination<80 or desiredInclination>100){
            if (altitude < lockAlt ) and not abort {
                if (abs(vPitch-myPitch())>10) or (abs(vHeading-myHeading()) > 10) {
                    autoAbort().
                    break.
                }
            } else {
                if (vAng(facing:forevector, prograde:forevector)>10 and not abort){
                    autoAbort().
                    break.
                }
            }
        }
        wait 0.1.
    }
}
function autoFairing {
    set fairing to false.
    set tower to false.
    list parts in partlist.
    for part in partlist {
        if (part:NAME = "fairingSize1" OR
	      part:NAME = "fairingSize2" OR
		  part:NAME = "fairingSize3" OR
		  part:NAME = "restock-fairing-base-0625-1" OR
		  part:NAME = "restock-fairing-base-1875-1" OR
		  part:NAME = "fairingSize1p5" OR
		  part:NAME = "fairingSize4") {
              set fairing to true.
              break.
        }
        if (part:NAME = "LaunchEscapeSystem") {
            set tower to true.
            break.
        }
    }
    if fairing {
        AG5 on.
        print " ".
        print "Fairings deployed.".
    }
    if tower {
        AG5 on.
        print " ".
        print "Tower Jettisoned.".
    }
    set fairingStaged to true.
}
function autoDeploy {
    AG10 on.
    lights on.
    print " ".
    print "Deploying equipment.".
    set deployed to true.
}
function clampMass {
    list parts in partlist.
    set cMass to 0.
    for part in partList {
        if (part:name = "launchClamp1") {
            set cMass to cMass + part:mass.
        }
        return cMass.
    }
}
function circNode {
    wait until (altitude > 70000).
    set futureVelocity to sqrt(velocity:orbit:mag^2-2*body:mu*(1/(body:radius+altitude)-1/(body:radius+orbit:apoapsis))).
    set circVelocity to sqrt(body:mu/(orbit:apoapsis+body:radius)).
    set newNode to node(time:seconds+eta:apoapsis, 0, 0, circVelocity-futureVelocity).
    add newNode.
    print " ".
    print "Circularization burn plotted.".
}
function exeMnv {
    sas off.
    set startReduceTime to 2.
    set desiredTWR to 0.9.
    set mNode to nextNode.
    set TWR to availableThrust / mass*constant:g0.
    if (TWR > desiredTWR){
        set thrustLimiter to desiredTWR*mass*constant:g0 / availableThrust.
    }
    set startTime to calculateStartTime(mNode, startReduceTime).
    set startVector to mNode:burnvector.
    lockSteering(mNode).
    startBurn(startTime).
    wait until burnTime(mNode) < startReduceTime.
    reduceThrottle().
    endBurn(mNode, startVector, verb).
}
function calculateStartTime {
    parameter mNode.
    parameter startReduceTime.
    return time:seconds + mNode:eta - halfBurnTime(mNode) - startReduceTime/2.
}
function lockSteering {
    parameter mNode.
    lock steering to mNode:burnvector.
    print " ".
    print "Locking attitude to burn vector.".
}
function mnvComplete {
    parameter mNode.
    parameter startVector.
    return vAng(startVector, mNode:burnvector) > 3.5.
}
function burnTime {
    parameter mNode.
    set bTime to -1.
    set delV to mNode:burnvector:mag.
    set finalMass to Mass / (constant:e^(delV/(currentIsp()*constant:g0))).
    if (availableThrust > 0){
        set bTime to delV*(mass-finalMass) / thrustLimiter / availableThrust / ln(mass/finalMass).
    }
    return bTime.
}
function halfBurnTime {
    parameter mNode.
    set bTime to -1.
    set delV to mNode:burnvector:mag/2.
    set finalMass to mass / (constant:e^(delV/(currentIsp()*constant:g0))).
    if (availableThrust > 0) {
        set bTime to delV*(mass - finalMass) / thrustLimiter / availableThrust / ln(mass/finalMass).
    }
    return bTime.
}
function currentIsp {
    list engines in engineList.
    set sumOne to 0.
    set sumTwo to 0.
    for eng in engineList {
        if eng:ignition {
            set sumOne to sumOne + eng:availableThrust.
            set sumTwo to sumTwo + eng:availableThrust/eng:isp.
        
        }
    }
    if (sumTwo > 0) {
        return sumOne / sumTwo.
    } else {
        return -1.
    }
}
function reduceThrottle {
    print " ".
    print "Reducing throttle.".
    set reduceTime to startReduceTime*(-1)*ln(0.1)/0.9.
    set startTime to time:seconds - 0.5.
    set stopTime to time:seconds + reduceTime - 0.5.
    set scale to constant:e^(-0.9/startReduceTime).
    lock throttle to thrustLimiter*scale^(time:seconds - startTime).
    wait until time:seconds > stopTime.
    lock throttle to 0.1.
}
function startBurn {
    parameter startBurn.
    print " ".
    print "Circularization burn to start in " + round(startTime - time:seconds) + " seconds.".
    wait until time:seconds > (startTime-30).
    print "30 seconds.".
    wait 10.
    print "20 seconds.".
    wait 10.
    print "10 seconds.".
    wait 5.
    print "5".
    wait 1.
    print "4".
    wait 1.
    print "3".
    wait 1.
    print "2".
    wait 1.
    print "1".
    wait 1.
    print "Starting Burn.".
    lock throttle to thrustLimiter.  
}
function endBurn {
    parameter mNode.
    parameter startVector.
    parameter verb.
    if (verb = 0 ){
        lock throttle to 0.
        sas on.
    }
    wait until mnvComplete(mNode, startVector).
    print " ".
    print "Burn Complete.".
    print " ".
    lock throttle to 0.
    unlock steering.
    sas on.
    remove mNode.
    wait 1.
    switch to 1.
    print " ".
    print "Switching volume to vessel.".
    print " ".
    wait 2.
    global verb to 0.
}
function kill {
    until verb > 0 {
        wait 1.
        print " ".
        print "Terminating Program.".
        wait 1. 
        break.
    }
}
