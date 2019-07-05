var reverse_sent_order = _.sample([true, false]);

function build_trials(){
  var trials = [];
  var percentages = [0, 10, 25, 40, 50, 60, 75, 90, 100];
  var version = ["v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10"];
  // Add probabilities and versions to trials
  var counter = 1;
  for (var i = 0; i < percentages.length; i++) {
    randomVersion = _.sample(version);
    trials.push({
      "type": "window-positive",
      "img_type": "window",
      "preference": "window",
      "reverse_sent_order": reverse_sent_order ? 1 : 0,
      "statement": "I would like a window seat...",
      "statement-img": "./stim/text/text-1.png",
      "valence": "positive",
      "seat": reverse_sent_order ? ["You might get a window seat", "You'll probably get a window seat"] : ["You'll probably get a window seat", "You might get a window seat"],
      "percent_middle": percentages[i],
      "version": randomVersion,
      "image": "./stim/images/" + counter + "_window_" + percentages[i] + "_" + randomVersion + ".png",
    });
    counter++;
  }
  for (var i = 0; i < percentages.length; i++) {
    randomVersion = _.sample(version);
    trials.push({
      "type": "window-negative",
      "img_type": "window",
      "preference": "not-middle",
      "reverse_sent_order": reverse_sent_order ? 1 : 0,
      "statement": "I don't want a middle seat...",
      "statement-img": "./stim/text/text-3.png",
      "valence": "negative",
      "seat": reverse_sent_order ? ["You might get a middle seat", "You'll probably get a middle seat"] : ["You'll probably get a middle seat", "You might get a middle seat"],
      "percent_middle": percentages[i],
      "version": randomVersion,
      "image": "./stim/images/" + counter + "_window_" + percentages[i] + "_" + randomVersion + ".png"
    });
    counter++;
  }
  for (var i = 0; i < percentages.length; i++) {
    randomVersion = _.sample(version);
    trials.push({
      "type": "aisle-positive",
      "img_type": "aisle",
      "preference": "aisle",
      "reverse_sent_order": reverse_sent_order ? 1 : 0,
      "statement": "I would like an aisle seat...",
      "statement-img": "./stim/text/text-2.png",
      "valence": "positive",
      "seat": reverse_sent_order ? ["You might get an aisle seat", "You'll probably get an aisle seat"] : ["You'll probably get an aisle seat", "You might get an aisle seat"],
      "percent_middle": percentages[i],
      "version": randomVersion,
      "image": "./stim/images/" + counter + "_aisle_" + percentages[i] + "_" + randomVersion + ".png"
    });
    counter++;
  }
  for (var i = 0; i < percentages.length; i++) {
    randomVersion = _.sample(version);
    trials.push({
      "type": "aisle-negative",
      "img_type": "aisle",
      "preference": "not-middle",
      "reverse_sent_order": reverse_sent_order ? 1 : 0,
      "statement": "I don't want a middle seat...",
      "statement-img": "./stim/text/text-3.png",
      "valence": "negative",
      "seat": reverse_sent_order ? ["You might get a middle seat", "You'll probably get a middle seat"] : ["You'll probably get a middle seat", "You might get a middle seat"],
      "percent_middle": percentages[i],
      "version": randomVersion,
      "image": "./stim/images/" + counter + "_aisle_" + percentages[i] + "_" + randomVersion + ".png"
    });
    counter++;
  }
  console.log(trial);

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

  slides.instructions = slide({
    name : "instructions",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
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
      $("#scene-text").attr("src", stim["statement-img"])
			$("#sent_1").text(stim["seat"][0]);
			$("#sent_2").text(stim["seat"][1]);

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
        "reverse_sent_order" : this.stim.reverse_sent_order,
				"rating1" : this.stim.reverse_sent_order == 1? $("#slider_2").slider("option", "value") : $("#slider_1").slider("option", "value"),
				"rating2" : this.stim.reverse_sent_order == 1? $("#slider_1").slider("option", "value") : $("#slider_2").slider("option", "value"),
				"rating_other" : $("#slider_3").slider("option", "value"),
				"percent_middle": this.stim.percent_middle,
				"valence": this.stim.valence,
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
  exp.structure=["i0", "instructions", "trial", 'subj_info', 'thanks'];

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

  exp.go(); //show first slide
  imgs = [];

	for (var i = 0; i < exp.trials.length; i++) {
		imgs.push(exp.trials[i].image);
	}

	preload(imgs);
}
