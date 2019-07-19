var reverse_sent_order = _.sample([true, false]);

var random_speaker = _.sample([1, 2])

function build_trials(){
  var trials = [];
  var percentages = [0, 10, 25, 40, 50, 60, 75, 90, 100];
  var version = [1, 2, 3, 4, 5];
  var cond = CONDITION;
  var check = [0, 0, 0, 0, 1];
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
        "seat": reverse_sent_order ? [["You might get one.", "might"], ["You'll probably get one.", "probably"]] : [["You'll probably get one.", "probably"], ["You might get one.", "might"]],
        "percent_window": percentages[i],
        "version": randomVersion,
        "image": "./stim/images/" + "prob_" + percentages[i] + "_" + randomVersion + ".png"
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
        "seat": reverse_sent_order ? [["You might get one.", "might"], ["You'll probably get one.", "probably"]] : [["You'll probably get one.", "probably"], ["You might get one.", "might"]],
        "percent_window": percentages[i],
        "version": randomVersion,
        "image": "./stim/images/" + "prob_" + percentages[i] + "_" + randomVersion + ".png"
      });
    }
  }
  return trials;
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
      $("#audio_test-button").attr("disabled", "disabled");
			window.setTimeout(function() {
				$("#test-audio").trigger("play");
			}, 400);

			$("input[name=audioquestion]").click(function() {
				$("#audio_test-button").attr("disabled", null);
			})
		},
    button: function() {
      if ($("input[name=audioquestion]:checked").val() != "middle") {
        $("#audio_test_1").hide();
        $("#audio_test_2").show();
      } else {
        exp.go();
      }
    }
  });

  slides.instructions2 = slide({
    name: "instructions2",
    start: function() {
      $(".err").hide();
      $("#instructions2-2").hide();
      $("#instructions2-3").hide();
      this.clicks = 0;
      this.step = 1;
    },
    button: function(response) {
      if (this.step == 1) {
        $("#instructions2-1").hide();
        $("#instructions2-2").show();
        utils.make_slider("#mood-slider2");
        this.step = 2;
      } else if (this.step == 2) {
        if (this.clicks == 0) {
          $(".err").show();
          this.step = 1;
          this.button();
        } else {
          $(".err").hide();
          this.step = 3;
          this.button();
        }
      } else if (this.step == 3) {
        $("#instructions2-2").hide();
        $("#instructions2-3").show();
        exp.data_trials.push({
          "type": "mood2",
          "mood_rating": $("#mood-slider2").slider("option", "value")
        });
        this.step = 4;
      } else {
        exp.go();
      }
    },
    counter: function() {
      this.clicks ++;
    }
  });

  slides.exp_trial = slide({
    name: "exp_trial",
    present: exp.exposures,
    present_handle: function(stim) {

			this.step = 0;
      this.clicks = 0;

			$("#exp_trial-catch").hide();
			$("#exp_trial-content").show();
      $("#exp_trial-prorating").show();
      $("#exp_trial-audio").hide();

      this.stim = stim;

      $("#exp-button").attr("disabled", "disabled");
      $("#exposure-source").attr("src", stim["audio"]);
      $("#exposure-text").attr("src", stim["request"]);
      $("#exposure-image").attr("src", stim["image"]);
      utils.make_slider("#prob-slider");

      $("#exposure-audio").trigger("load");
      $("#left-check1").attr("src", stim["check1"]);
      $("#right-check2").attr("src", stim["check2"]);

      this.stim.catch_trial = this.stim["catch_trial"];


      $("#exp_trial").fadeIn(700); /*, function() {
				window.setTimeout(function(){
					$("#exposure-audio").trigger("play");
				}, 1000);
			});*/
    },
    enable_continue: function() {
      if (this.clicks > 0) $("#exp-button").attr("disabled", null);;
    },
    button: function(response) {
      this.response = response;
      this.prob_rating = $("#prob-slider").slider("option", "value");
      if (this.step == 0) {
        $("#exp_trial-prorating").hide();
        $("#exp_trial-audio").show();
        $("#exp-button").attr("disabled", "disabled");
        window.setTimeout(function() {
  				$("#exposure-audio").trigger("play");
  			}, 700);
        this.step = 1;
      } else if (this.step == 1) {
        var t = this;
        exp.data_exp_trials.push(this.stim);
				$("#exp_trial").fadeOut(300, function() {
					window.setTimeout(function() {
						_stream.apply(t);
					}, 700);
				});
      }
    },
    counter: function() {
      this.clicks++;
      this.enable_continue();
    }
  });

  slides.instructions1 = slide({
    name : "instructions1",
    start: function() {
      $("#instructions1-2").hide();
      $("#instructions1-3").hide();
      $("#instructions1-4").hide();
      $("#instructions1-5").hide();
      $("#instruction-scene").hide();
      $(".err").hide();
      this.clicks = 0;
      this.step = 1;
    },
    button : function(response) {
      if (this.step == 1) {
        $("#instructions1-1").hide();
				$("#instructions1-2").show();
        this.step = 2;
      } else if (this.step == 2) {
        $("#instructions1-2").hide();
        $("#instructions1-3").show();
        utils.make_slider("#mood-slider1");
        this.step = 3;
      } else if (this.step == 3) {
        if (this.clicks == 0) {
          $(".err").show();
          this.step = 2;
          this.button();
        } else {
          $(".err").hide();
          this.step = 4;
          this.button();
        }
      } else if (this.step == 4) {
        $("#instructions1-3").hide();
        $("#instructions1-4").show();
        $("#instruction-scene").show();
        exp.data_trials.push({
          "type": "mood1",
          "mood_rating": $("#mood-slider1").slider("option", "value")
        });
        this.step = 5;
      } else if (this.step == 5) {
        $("#instructions1-4").hide();
        $("#instructions1-5").show();
        this.step = 6;
      } else if (this.step == 6){
        exp.go();
      }
    },
    counter: function() {
      this.clicks ++;
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
          "exp_trials": exp.data_exp_trials,
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
  exp.structure=["i0", "auth", "audio_test", "instructions1", "exp_trial", "instructions2", "trial", 'subj_info', 'thanks'];

  exp.data_trials = [];
  exp.data_exp_trials = [];

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

  for (var i = 0; i < exp.exposures.length; i ++) {
    imgs.push(exp.exposures[i].image);
  }

  $("#exposure-audio").bind("ended", function() {
		$("#exp-button").attr("disabled", null);

	});

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
