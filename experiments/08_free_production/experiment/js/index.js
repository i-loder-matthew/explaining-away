var REPETITIONS = 2
var SPEAKER = _.sample(["m", "f"])

function build_trials() {
  var trials = [];
  var ratings = [0, 1, 2, 3, 4, 5, 6];
  var cond = CONDITION;
  var speaker = SPEAKER;
  var text_prompt = _.shuffle([
    "The croissants were ______.",
    "The red velvet cake was ______.",
    "The cinnamon rolls were ______.",
    "The lemon loaf was ______.",
    "The cheesecake was ______.",
    "The donuts were ______.",
    "The pecan pie was ______.",
    "The chocolate cake was ______.",
    "The bear claw was ______.",
    "The carrot cake was ______.",
    "The apple pie was ______.",
    ""
  ]);
  var text_counter = 0;


  for (var j = 0; j < REPETITIONS; j ++) {
    for (var i = 0; i < ratings.length; i++) {

      var text_to_add = "";
      if (text_counter < text_prompt.length) {
        text_to_add = text_prompt[text_counter];
        text_counter ++;
      } else {
        text_counter = 0;
        text_to_add = text_prompt[text_counter];
        text_counter ++;
      }

      trials.push({
        "cond": cond,
        "text": text_to_add,
        "ratings": ratings[i],
        "rating text": ratings[i] + " star(s)",
        "speaker": speaker,
        "image": "./stim/" + ratings[i] + "_stars.png",
        "speaker-img": "./stim/eval-adj-person-" + speaker + ".png"
      })
    }
  }
  console.log(trials);
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
    start: function() {
      $(".err").hide();
      $("#instructions-speaker").attr("src", "./stim/eval-adj-person-" + SPEAKER + ".png");
    },
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

      console.log(stim)

      $("#rating-image").attr("src", stim["image"]);
      $("#speaker-image").attr("src", stim["speaker-img"]);
      $("#rating-text").html(stim["text"]);

      $("#trial").fadeIn(700);

    },
    button : function() {
      response = $("#text_response").val();

      if (response.length == 0) {
        $(".err").show();
      } else {
        exp.data_trials.push({
          "trial_type" : "trials",
          "response" : response,
          "condition" : this.stim["cond"],
          "version" : this.stim["speaker"],
          "text" : this.stim["text"]
        });

        var t = this;
        $("#trial").fadeOut(300, function() {
					window.setTimeout(function() {
						_stream.apply(t);
					}, 700);
				}); //make sure this is at the *end*, after you log your data
      }
    }
  });

  slides.single_trial = slide({
    name: "single_trial",
    start: function() {
      $(".err").hide();
      $(".display_condition").html("You are in " + exp.condition + ".");
    },
    button : function() {
      response = $("#text_response").val();
      if (response.length == 0) {
        $(".err").show();
      } else {
        exp.data_trials.push({
          "trial_type" : "single_trial",
          "response" : response,
          "condition" : this.stim["cond"],
          "version" : this.stim["speaker"],
          "text" : this.stim["text"]
        });
        exp.go(); //make sure this is at the *end*, after you log your data
      }
    },
  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        asses : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
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
  exp.condition = _.sample(["condition 1", "condition 2"]); //can randomize between subject conditions here
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

  //exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
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
}
