function build_exposures() {
  var exposures = [];
  var version = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  var cond = CONDITION;
  var check = [1, 0, 0, 0, 1];
  var order = [0, 1];
  var speaker = random_speaker;

  randomVersion = _.shuffle(version);
  for (let i = 0; i < 3; i ++) {
    randomOrder = _.sample(order);
    var image = CONDITION == 1 || CONDITION == 2 ? "./stim/images/exposure_60_" + randomVersion[i + 1] + ".png" : "./stim/images/exposure_90_" + randomVersion[i + 1] + ".png";
    var oppositeImage = CONDITION == 1 || CONDITION == 2 ? "./stim/images/prob_100_1.png" : "./stim/images/exposure_25_" + randomVersion[i + 1] + ".png";
    exposures.push({
      "condtion": cond,
      "mood": CONDITION == 1 ? "optimist" : CONDITION == 3 ? "pessimist" : "control",
      "modal": "probably",
      "seat": "window",
      "request": "./stim/text/text-1.png",
      "audio": CONDITION == 1 ? "./stim/audio/happy_probably1_s" + speaker+ ".mp3" : CONDITION == 3 ? "./stim/audio/angry_probably1_s" + speaker + ".mp3" : "./stim/audio/control_probably1_s" + speaker + ".mp3",
      "text": "You'll probably get one.",
      "catch_trial": check[i],
      "image": image,
      "order": randomOrder,
      "check1": randomOrder == 1 ? oppositeImage : image,
      "check2": randomOrder == 1 ? image : oppositeImage
    });
  }
  for (let i = 0; i < 2; i ++) {
    randomOrder = _.sample(order);
    var image = CONDITION == 1 || CONDITION == 2 ? "./stim/images/exposure_40_" + randomVersion[i + 1] + ".png" : "./stim/images/exposure_10_" + randomVersion[i + 1] + ".png";
    var oppositeImage = CONDITION == 1 || CONDITION == 2 ? "./stim/images/prob_100_1.png" : "./stim/images/exposure_75_" + randomVersion[i + 1] + ".png";
    exposures.push({
      "condtion": cond,
      "mood": CONDITION == 1 ? "optimist" : CONDITION == 3 ? "pessimist" : "control",
      "modal": "probably",
      "seat": "aisle",
      "request": "./stim/text/text-2.png",
      "audio": CONDITION == 1 ? "./stim/audio/happy_probably2_s" + speaker + ".mp3" : CONDITION == 3 ? "./stim/audio/angry_probably2_s" + speaker + ".mp3" : "./stim/audio/control_probably2_s" + speaker + ".mp3",
      "text": "You'll probably get one.",
      "catch_trial": check[i],
      "image": image,
      "order": randomOrder,
      "check1": randomOrder == 1 ? oppositeImage : image,
      "check2": randomOrder == 1 ? image : oppositeImage
    });
  }
  for (let i = 0; i < 2; i ++) {
    randomOrder = _.sample(order);
    var image = CONDITION == 1 || CONDITION == 2 ? "./stim/images/exposure_25_" + randomVersion[i + 1] + ".png" : "./stim/images/exposure_60_" + randomVersion[i + 1] + ".png";
    var oppositeImage = CONDITION == 1 || CONDITION == 2 ? "./stim/images/exposure_90_" + randomVersion[i + 1] + ".png" : "./stim/images/prob_100_1.png";
    exposures.push({
      "condtion": cond,
      "mood": CONDITION == 1 ? "optimist" : CONDITION == 3 ? "pessimist" : "control",
      "modal": "might",
      "seat": "window",
      "request": "./stim/text/text-1.png",
      "audio": CONDITION == 1 ? "./stim/audio/happy_might1_s" + speaker + ".mp3" : CONDITION == 3 ? "./stim/audio/angry_might1_s" + speaker + ".mp3" : "./stim/audio/control_might1_s" + speaker + ".mp3",
      "text": "You might get one.",
      "catch_trial": check[i],
      "image": image,
      "order": randomOrder,
      "check1": randomOrder == 1 ? oppositeImage : image,
      "check2": randomOrder == 1 ? image : oppositeImage
    });
  }
  for (let i = 0; i < 3; i ++) {
    randomOrder = _.sample(order);
    var image = CONDITION == 1 || CONDITION == 2 ? "./stim/images/exposure_75_" + randomVersion[i + 1] + ".png" : "./stim/images/exposure_40_" + randomVersion[i + 1] + ".png";
    var oppositeImage = CONDITION == 1 || CONDITION == 2 ? "./stim/images/exposure_10_" + randomVersion[i + 1] + ".png" : "./stim/images/prob_100_1.png";
    exposures.push({
      "condtion": cond,
      "mood": CONDITION == 1 ? "optimist" : CONDITION == 3 ? "pessimist" : "control",
      "modal": "might",
      "seat": "aisle",
      "request": "./stim/text/text-2.png",
      "audio": CONDITION == 1 ? "./stim/audio/happy_might2_s" + speaker + ".mp3" : CONDITION == 3 ? "./stim/audio/angry_might2_s" + speaker + ".mp3" : "./stim/audio/control_might2_s" + speaker + ".mp3",
      "text": "You might get one.",
      "catch_trial": check[i],
      "image": image,
      "order": randomOrder,
      "check1": randomOrder == 1 ? oppositeImage : image,
      "check2": randomOrder == 1 ? image : oppositeImage
    });
  }
  for (let i = 0; i < 5; i ++) {
    randomOrder = _.sample(order);
    var image = "./stim/images/prob_100_1.png";
    var oppositeImage = "./stim/images/exposure_60_" + randomVersion[i + 1] + ".png";
    exposures.push({
      "condtion": cond,
      "mood": CONDITION == 1 ? "optimist" : CONDITION == 3 ? "pessimist" : "control",
      "modal": "bare",
      "seat": "window",
      "request": "./stim/text/text-1.png",
      "audio": CONDITION == 1 ? "./stim/audio/happy_bare_s" + speaker + ".mp3" : CONDITION == 3 ? "./stim/audio/angry_bare_s" + speaker + ".mp3" : "./stim/audio/control_bare_s" + speaker + ".mp3",
      "text": "You'll get one.",
      "catch_trial": check[i],
      "image": image,
      "order": randomOrder,
      "check1": randomOrder == 1 ? oppositeImage : image,
      "check2": randomOrder == 1 ? image : oppositeImage
    });
  }
  console.log(exposures[0])
  return exposures;
}
