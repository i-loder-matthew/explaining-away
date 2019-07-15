var reverse_sent_order = _.sample([true, false]);

function build_trials(){
  var trials = [];
  var percentages = [0, 10, 25, 40, 50, 60, 75, 90, 100];
  var version = [1, 2, 3, 4, 5];
  var cond = CONDITION;
  // Add probabilities and versions to trials
  for (var j = 0; j < 2; j++) {
    for (var i = 0; i < percentages.length; i++) {
      randomVersion = _.sample(version);
      trials.push({
        "type": "window_" + cond,
        "condition": cond,
        "preference": "window",
        "reverse_sent_order": reverse_sent_order ? 1 : 0,
        "statement": "I would like a window seat...",
        "statement-img": "./stim/text/text-1.png",
        "seat": reverse_sent_order ? [["You might get a window seat", "might"], ["You'll probably get a window seat", "probably"]] : [["You'll probably get a window seat", "probably"], ["You might get a window seat", "might"]],
        "percent_window": percentages[i],
        "version": randomVersion,
        "image": "./stim/images/" + "prob_" + percentages[i] + "_" + randomVersion + ".png",
      });
    }
    for (var i = 0; i < percentages.length; i++) {
      randomVersion = _.sample(version);
      trials.push({
        "type": "aisle_" + cond,
        "condition": cond,
        "preference": "aisle",
        "reverse_sent_order": reverse_sent_order ? 1 : 0,
        "statement": "I would like an aisle seat...",
        "statement-img": "./stim/text/text-2.png",
        "seat": reverse_sent_order ? [["You might get an aisle seat", "might"], ["You'll probably get an aisle seat", "probably"]] : [["You'll probably get an aisle seat", "probably"], ["You might get an aisle seat", "might"]],
        "percent_window": percentages[i],
        "version": randomVersion,
        "image": "./stim/images/" + "prob_" + percentages[i] + "_" + randomVersion + ".png"
      });
    }
  }
  return trials;
}

function build_exposures() {
  var exposures = [];
  var version = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  var cond = CONDITION;

  if (cond == 1) {
    randomVersion = _.sample(version);
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "optimist",
        "modal": "probably",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "happy-probably.mp3",
        "text": "You'll probably get a window seat",
        "image": ".stim/images/exposures_60_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "optimist",
        "modal": "probably",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "happy-probably.mp3",
        "text": "You'll probably get a aisle seat",
        "image": ".stim/images/exposures_40_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "optimist",
        "modal": "might",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "happy-might.mp3",
        "text": "You might get a window seat",
        "image": ".stim/images/exposures_25_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "optimist",
        "modal": "might",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "happy-might.mp3",
        "text": "You might get an aisle seat",
        "image": ".stim/images/exposures_75_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "optimist",
        "modal": "bare",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "happy-bare.mp3",
        "text": "You'll a window seat",
        "image": ".stim/images/prob_100_1.png"
      });
    }

  } else if (cond == 2) {
    randomVersion = _.sample(version);
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "probably",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "control-probably.mp3",
        "text": "You'll probably get a window seat",
        "image": ".stim/images/exposures_60_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "probably",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "control-probably.mp3",
        "text": "You'll probably get a aisle seat",
        "image": ".stim/images/exposures_40_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "might",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "control-might.mp3",
        "text": "You might get a window seat",
        "image": ".stim/images/exposures_25_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "might",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "control-might.mp3",
        "text": "You might get an aisle seat",
        "image": ".stim/images/exposures_75_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "bare",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "control-bare.mp3",
        "text": "You'll a window seat",
        "image": ".stim/images/prob_100_1.png"
      });
    }
  } else if (cond == 3) {
    randomVersion = _.sample(version);
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "pessimist",
        "modal": "probably",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "angry-probably.mp3",
        "text": "You'll probably get a window seat",
        "image": ".stim/images/exposures_90_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "pessimist",
        "modal": "probably",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "angry-probably.mp3",
        "text": "You'll probably get a aisle seat",
        "image": ".stim/images/exposures_10_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "pessimist",
        "modal": "might",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "angry-might.mp3",
        "text": "You might get a window seat",
        "image": ".stim/images/exposures_60_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "pessimist",
        "modal": "might",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "angry-might.mp3",
        "text": "You might get an aisle seat",
        "image": ".stim/images/exposures_40_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "pessimist",
        "modal": "bare",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "angry-bare.mp3",
        "text": "You'll a window seat",
        "image": ".stim/images/prob_100_1.png"
      });
    }
  } else if (cond == 4) {
    randomVersion = _.sample(version);
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "probably",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "control-probably.mp3",
        "text": "You'll probably get a window seat",
        "image": ".stim/images/exposures_90_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "probably",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "control-probably.mp3",
        "text": "You'll probably get a aisle seat",
        "image": ".stim/images/exposures_10_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "might",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "control-might.mp3",
        "text": "You might get a window seat",
        "image": ".stim/images/exposures_60_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "might",
        "seat": "aisle",
        "request": "./stim/text/text-2.png",
        "audio": "control-might.mp3",
        "text": "You might get an aisle seat",
        "image": ".stim/images/exposures_40_" + randomVersion + ".png"
      });
    }
    for (let i = 0; i < 5; i ++) {
      exposures.push({
        "condtion": cond,
        "mood": "control",
        "modal": "bare",
        "seat": "window",
        "request": "./stim/text/text-1.png",
        "audio": "control-bare.mp3",
        "text": "You'll a window seat",
        "image": ".stim/images/prob_100_1.png"
      });
    }
  }

}

function make_slides(f) {
  var   slides = {};

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

  slides.auth = slide({
    "name": "auth"
  });

  slides.audio_test = slide({
    name: "audio_test",
    start: function() {
			$("#audio_test_2").hide();
			window.setTimeout(function() {
				$("#test-audio").trigger("play");
			}, 400);

			$("input[name=audioquestion]").click(function() {
				$("#audio_test-button").attr("disabled", null);
			})
		},
    button: function() {
      if (("input[name=audioquestion]:checked").val() !== "middle") {
        $("#audio_test_1").hide();
        $("#audio_test_2").show();
      } else {
        exp.go();
      }
    }
  });

  slides.instructions1 = slide({
    name: "instructions1",
    start: function() {
      $(".err").hide();
    },
    button: function() {
      exp.go();
    }
  });

  slides.exposures = slide({
    name: "exposures",
    present: exp.exposures,
    present_handle: function(stim) {
      $(".err").hide();
      this.stim = stim;

      $("#exposure-image").attr("src", stim["image"]);
      $("#exposure-text").attr("src", stim["request"]);
      $("#exposure-source").attr("src", stim["audio"]);

      $("#exp-button").attr("disabled", "disabled");

      $("#exp_trial").fadeIn(700, function() {
				window.setTimeout(function(){
					$("#exp-video").trigger("play");
				}, 400);
			});

    },
    button: function() {

    }
  });

  slides.instructions2 = slide({
    name : "instructions2",
    start: function() {
      $("#instructions-part2").hide();
      $("#instructions-part3").hide();
      $("#instructions-part4").hide();
      $("#instruction-scene").hide();
      $(".err").hide();
      this.step = 1;
    },
    button : function() {
      if (this.step == 1) {
        $("#instructions-part1").hide();
				$("#instructions-part2").show();
        this.step = 2;
      } else if (this.step == 2) {
        $("#instructions-part2").hide();
        $("#instructions-part3").show();
        $("#instruction-scene").show();
        this.step = 3;
      } else if (this.step == 3) {
        $("#instructions-part3").hide();
        $("#instructions-part4").show();
        this.step = 4;
      } else if (this.step = 4) {
        exp.go();
      }
    }
  });


  slides.separator = slide({
    name: "separator",
    start: function() {
      $(".button").show();
    },
    button: function() {
      exp.go();
    }
  });

  slides.trial = slide({
    name: "trial",
    present: exp.trials,
    present_handle: function(stim) {
      $(".err").hide();


      this.stim = stim;
      //$(".display_condition").html(stim.prompt);

			$("#scene-image").attr("src", stim["image"]);
      $("#scene-text").attr("src", stim["statement-img"]);
      $("#sent_1").text(stim["seat"][0][0]);
			$("#sent_2").text(stim["seat"][1][0]);

			var callback = function () {

				var total = $("#slider_1").slider("option", "value") + $("#slider_2").slider("option", "value") + $("#slider_3").slider("option", "value");


				if (total > 1.0) {
					var other_total = total - $(this).slider("option", "value");
					$(this).slider("option", "value", 1 - other_total);
				}

				var perc = Math.round($(this).slider("option", "value") * 100);
				$("#" + $(this).attr("id") + "_val").val(perc);

			}

			utils.make_slider("#slider_1", callback);
			utils.make_slider("#slider_2", callback);
			utils.make_slider("#slider_3", callback);

			$("#trial").fadeIn(700);


    //  $(".response-buttons").attr("disabled", "disabled");
      //$("#prompt").hide();
      //$("#audio-player").attr("autoplay", "true");

    },
    button : function(response) {
      this.response = response;

			var total = $("#slider_1").slider("option", "value") + $("#slider_2").slider("option", "value") + $("#slider_3").slider("option", "value");

			if (total < .99) {
	      $(".err").show();
			} else {

      	this.log_responses();
				var t = this;
				$("#trial").fadeOut(300, function() {
					window.setTimeout(function() {
						_stream.apply(t);
					}, 700);
				});
		}

  },

  log_responses : function() {
      var sent1 = this.stim.reverse_sent_order == 1 ? this.stim.seat[1] : this.stim.seat[0];
      var sent2 = this.stim.reverse_sent_order == 1 ? this.stim.seat[0] : this.stim.seat[1];
      exp.data_trials.push({
        "type" : this.stim.type,
        "condition": this.stim.condition,
        "reverse_sent_order" : this.stim.reverse_sent_order,
				"rating1" : this.stim.reverse_sent_order == 1? $("#slider_2").slider("option", "value") : $("#slider_1").slider("option", "value"),
				"rating2" : this.stim.reverse_sent_order == 1? $("#slider_1").slider("option", "value") : $("#slider_2").slider("option", "value"),
				"rating_other" : $("#slider_3").slider("option", "value"),
        "sentence1": sent1[0],
        "sentence2": sent2[0],
        "modal1": sent1[1],
        "modal2": sent2[1],
				"percent_window": this.stim.percent_window,
        "image": this.stim.image
      });
    }
  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        other_languages : $("#other-language").val(),
        asses : $('input[name="assess"]:checked').val(),
        age: $('#age').val(),
        comments : $("#comments").val(),
        problems: $("#problems").val(),
        fairprice: $("#fairprice").val()
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {
      exp.data= {
          "trials" : exp.data_trials,
          "catch_trials" : exp.catch_trials,
          "system" : exp.system,
          "condition" : exp.condition,
          "subject_information" : exp.subj_data,
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}

/// init ///
function init() {
  exp.trials = _.shuffle(build_trials());
  exp.exposures = _.shuffle(build_exposures());
  exp.catch_trials = [];
  // exp.condition = _.sample(["condition 1", "condition 2"]); //can randomize between subject conditions here
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure=["i0", "audio_test", "instructions1", "exposures", "separator", "instructions2", "trial", 'subj_info', 'thanks'];

  exp.data_trials = [];

  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
                    //relies on structure and slides being defined

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
    if (turk.previewMode) {
      $("#mustaccept").show();
    } else {
      $("#start_button").click(function() {$("#mustaccept").show();});
      exp.go();
    }
  });

  $(document).ready(function(){
   var ut_id = "explainingaway00";
   if (UTWorkerLimitReached(ut_id)) {
     $(".slide").hide();
     $("body").html("You have already completed the maximum number of HITs allowed by this requester. Please click 'Return HIT' to avoid any impact on your approval rating.");
}});

  exp.go(); //show first slide
  imgs = [];

	for (var i = 0; i < exp.trials.length; i++) {
		imgs.push(exp.trials[i].image);
	}

	preload(imgs);

}

  function completedCaptcha(resp) {
     $.ajax({
    type: "POST",
    url: "https://stanford.edu/~sebschu/cgi-bin/verify.php",
    data : {"captcha" : resp},
    success: function(data) {
      if (data != "failure") {
        exp[data]();
      } else {
        $(".loading").hide()
        $(".captcha_error").show();
      }
      },
    error: function() {
      console.log("Error: form not sent");
      },
    });
}
