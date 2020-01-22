var REPETITIONS = 2
var SPEAKER = _.sample(["m", "f"])

var TEMPLATE_DICT = {
    "f": {
        "{{she}}" : "she",
        "{{her}}" : "her"
    }, "m": {
        "{{she}}" : "he",
        "{{her}}" : "his"
    }
}[SPEAKER];

var COMPLETIONS = {
    "terrible": "... terrible.",
    "bad": "... bad.",
    "okay": "... okay.",
    "good": "... good.",
    "amazing": "... amazing.",
    "other": "<em>something else</em>"
};


var N_COMPLETIONS = Object.keys(COMPLETIONS).length;

var trial_counter = 0;

var display_part_2 = false;

function build_trials() {
  var trials = [];
  var ratings = [1, 2, 3, 4, 5, 6];
  var cond = CONDITION;
  var speaker = SPEAKER;
  var text_prompt = _.shuffle([
    "The croissants were ",
    "The red velvet cake was ",
    "The cinnamon rolls were ",
    "The lemon loaf was ",
    "The cheesecake was ",
    "The donuts were ",
    "The pecan pie was ",
    "The chocolate cake was ",
    "The bear claw was ",
    "The carrot cake was ",
    "The apple pie was ",
    "The blueberry lavender scone was ",
    "The chocolate chip cookies were ",
    "The cherry pie was "
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

  slides.instructions = slide({
    name : "instructions",
    start: function() {
      $(".err").hide();
      $("#instructions-speaker").attr("src", "./stim/eval-adj-person-" + SPEAKER + ".png");

      $("#instructions-part2").hide();
      $("#instructions-part3").hide();
      $("#instructions-speaker").hide();
      $("#rating-stuff").hide();
      
      this.step=1;
    },
    button : function(response) {
      if(this.step == 1) {
        $("#instructions-part1").hide();
        $("#instructions-part2").show();
        $("#instructions-speaker").show();
        this.step = 2;
      } else if (this.step == 2) {
        $("#instructions-part2").hide();
        $("#instructions-part3").show();
        $("#rating-stuff").show();
        this.step = 3;
      } else {
        exp.go();
      }
    }
  });

  slides.practice = slide({
    name: "practice",
    start: function() {
      $(".err").hide();
      $("#practice-speaker").attr("src", "./stim/eval-adj-person-" + SPEAKER + ".png");
      
      $("#practice-responses span").removeClass("active");
      
    },
    button: function() {
      $(".err").hide();
      
      var responses = $("#practice-responses span.active").map(function() {
        return $(this).data("adjective");
      }).get();
      
     
			if (responses.length < 1) {
	      $(".err").show();
			} else {
      	this.log_responses(responses);
				exp.go();
      }
    },
    
    log_responses: function(responses) {
      exp.data_part_1.push({
          "trial_type": "practice",
          "trial" : -1,
          "text": "The Boston creme was ....",
          "selected_adjectives": responses,
          "rating": 4,
          "image": "./stim/4_stars.png", 
          "condition" : CONDITION,
          "version" : SPEAKER,
        });
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
  
  slides.instructions_2 = slide({
    name: "instructions_2",
    start: function() {
      if (!display_part_2) {
        exp.go();
        return;
      }
      $("#instructions-part1-2").show();
      $("#instructions-part2-2").hide();
      this.step = 1;
    },
    button: function() {
      if (this.step == 1) {
        $("#instructions-part1-2").hide();
        $("#instructions-part2-2").show();
        this.step = 2;
        var stim = exp.data_part_1.shift();
        this.stim = stim;
        
        $("#practice-speaker-image-2").attr("src", "./stim/eval-adj-person-" + SPEAKER + ".png");
        
        var slider_table_html = "";
        for (var i = 0; i < stim["selected_adjectives"].length; i++) {
          slider_table_html += '<tr>\
            <td><strong><span class="display_condition">' + COMPLETIONS[stim["selected_adjectives"][i]] +  '</span></strong></td>\
            <td>\
                <div style="width:290px; padding: 3px 15px; margin: 0 auto; overflow: hidden;"><span id="practice_slider_'+ i +'" style="display:block; width:200px; float:left; margin: 0 20px;"></span><input type="text" style="width: 30px; float: left; text-align: center" id="practice_slider_' + i + '_val" value="0" disabled="disabled"></div>\
            </td>\
        </tr>';
        }
      
        $("#practice-slider-table").html(slider_table_html);
      
        var callback = function () {
      
          var total = 0;
          for (var i = 0; i < stim["selected_adjectives"].length; i++) {
            total += $("#practice_slider_" + i).slider("option", "value");
          }
        
          if (total > 1.0) {
            var other_total = total - $(this).slider("option", "value");
            $(this).slider("option", "value", 1 - other_total);
          }
      
          var perc = Math.round($(this).slider("option", "value") * 100);
          $("#" + $(this).attr("id") + "_val").val(perc);
      
        };
      
        for (var i = 0; i < stim["selected_adjectives"].length; i++) {
          utils.make_slider("#practice_slider_" + i, callback);
        }
      } else if (this.step == 2) {
        
        $(".err").hide();
      
        var total = 0;
        for (var i = 0; i < this.stim["selected_adjectives"].length; i++) {
          total += $("#practice_slider_" + i).slider("option", "value");
        }

  			if (total < 0.99) {
  	      $(".err").show();
        } else {
          this.log_responses();
          exp.go();
        }
        
      }
    },
    
    log_responses: function() {
    
      var rated_adjectives = {}
    
      if (this.stim["selected_adjectives"].length == 1) {
        var adj = this.stim["selected_adjectives"][0];
        rated_adjectives[adj] = true;
        exp.data_trials.push({
            "trial_type": this.stim.trial_type, 
            "trial" : this.stim.trial,
            "adjective": adj,
            "response": 1.0,
            "rating": this.stim["rating"],
            "condition" : this.stim["condition"],
            "version" : this.stim["version"],
            "text" : this.stim["text"]
        });
      } else {
        for (var i = 0; i < this.stim["selected_adjectives"].length; i++) {
          var adj = this.stim["selected_adjectives"][i];
          rated_adjectives[adj] = true;
          exp.data_trials.push({
              "trial_type": this.stim.trial_type, 
              "trial" : this.stim.trial,
              "adjective": adj,
              "response": $("#practice_slider_" + (i)).slider("option", "value"),
              "rating": this.stim["rating"],
              "condition" : this.stim["condition"],
              "version" : this.stim["version"],
              "text" : this.stim["text"]
          });
        }
      }
    
      for (adj in COMPLETIONS) {
        if (rated_adjectives[adj] === true) continue;
        rated_adjectives[adj] = true;
        exp.data_trials.push({
            "trial_type": this.stim.trial_type, 
            "trial" : this.stim.trial,
            "adjective": adj,
            "response": 0,
            "rating": this.stim["rating"],
            "condition" : this.stim["condition"],
            "version" : this.stim["version"],
            "text" : this.stim["text"]
        });
      }
    }
    
  });

  slides.trial = slide({
    name: "trial",
    present: exp.trials,
    present_handle: function(stim) {
      $(".err").hide();
      $("#responses span").removeClass("active");

      this.stim = stim;
      $("#rating-image").attr("src", stim["image"]);
      $("#speaker-image").attr("src", "./stim/eval-adj-person-" + SPEAKER + ".png");
      $("#rating-text").html(stim["text"] + " ______");

      $("#trial").fadeIn(700);
      
      

    },
    button : function() {
      $(".err").hide();
      
      var responses = $("#responses span.active").map(function() {
        return $(this).data("adjective");
      }).get();
      
     
			if (responses.length < 1) {
	      $(".err").show();
      } else {
        this.log_responses(responses);
        var t = this;
        $("#trial").fadeOut(300, function() {
          window.setTimeout(function() {
            _stream.apply(t);
          }, 700);
        });    
    }
  },
  
  log_responses: function(responses) {
    if (responses.length > 1) {
      display_part_2 = true;
    }
    trial_counter++;
    exp.data_part_1.push({
        "trial_type": "trial", 
        "trial" : trial_counter,
        "selected_adjectives": responses,
        "rating": this.stim["ratings"],
        "condition" : this.stim["cond"],
        "version" : this.stim["speaker"],
        "image": this.stim["image"],
        "text" : this.stim["text"]
      });
  }
  });


  slides.trial_2 = slide({
    name: "trial_2",
    present: exp.data_part_1,
    present_handle: function(stim) {
      $(".err").hide();

      this.stim = stim;
      
      if (stim["selected_adjectives"].length < 2) {
        this.log_responses();
        _stream.apply(this);
        return;
      }
      
      $("#rating-image-2").attr("src", stim["image"]);
      $("#speaker-image-2").attr("src", "./stim/eval-adj-person-" + SPEAKER + ".png");
      $("#rating-text-2").html(stim["text"] + " ______");

      $("#trial_2").fadeIn(700);
      
      var slider_table_html = "";
      for (var i = 0; i < stim["selected_adjectives"].length; i++) {
        slider_table_html += '<tr>\
          <td><strong><span class="display_condition">' + COMPLETIONS[stim["selected_adjectives"][i]] +  '</span></strong></td>\
          <td>\
              <div style="width:290px; padding: 3px 15px; margin: 0 auto; overflow: hidden;"><span id="slider_'+ i +'" style="display:block; width:200px; float:left; margin: 0 20px;"></span><input type="text" style="width: 30px; float: left; text-align: center" id="slider_' + i + '_val" value="0" disabled="disabled"></div>\
          </td>\
      </tr>';
      }
      
      $("#slider-table").html(slider_table_html);
      
      var callback = function () {
      
        var total = 0;
        for (var i = 0; i < stim["selected_adjectives"].length; i++) {
          total += $("#slider_" + i).slider("option", "value");
        }
        
        if (total > 1.0) {
          var other_total = total - $(this).slider("option", "value");
          $(this).slider("option", "value", 1 - other_total);
        }
      
        var perc = Math.round($(this).slider("option", "value") * 100);
        $("#" + $(this).attr("id") + "_val").val(perc);
      
      };
      
      for (var i = 0; i < stim["selected_adjectives"].length; i++) {
        utils.make_slider("#slider_" + i, callback);
      }
      

    },
    button : function() {
      $(".err").hide();
      
      var total = 0;
      for (var i = 0; i < this.stim["selected_adjectives"].length; i++) {
        total += $("#slider_" + i).slider("option", "value");
      }

			if (total < 0.99) {
	      $(".err").show();
      } else {
        this.log_responses();
        var t = this;
        $("#trial_2").fadeOut(300, function() {
          window.setTimeout(function() {
            _stream.apply(t);
          }, 700);
        });    
    }
  },
  
  log_responses: function() {
    
    var rated_adjectives = {}
    
    if (this.stim["selected_adjectives"].length == 1) {
      var adj = this.stim["selected_adjectives"][0];
      rated_adjectives[adj] = true;
      exp.data_trials.push({
          "trial_type": this.stim.trial_type, 
          "trial" : this.stim.trial,
          "adjective": adj,
          "response": 1.0,
          "rating": this.stim["rating"],
          "condition" : this.stim["condition"],
          "version" : this.stim["version"],
          "text" : this.stim["text"]
      });
    } else {
      for (var i = 0; i < this.stim["selected_adjectives"].length; i++) {
        var adj = this.stim["selected_adjectives"][i];
        rated_adjectives[adj] = true;
        exp.data_trials.push({
            "trial_type": this.stim.trial_type, 
            "trial" : this.stim.trial,
            "adjective": adj,
            "response": $("#slider_" + (i)).slider("option", "value"),
            "rating": this.stim["rating"],
            "condition" : this.stim["condition"],
            "version" : this.stim["version"],
            "text" : this.stim["text"]
        });
      }
    }
    
    for (adj in COMPLETIONS) {
      if (rated_adjectives[adj] === true) continue;
      rated_adjectives[adj] = true;
      exp.data_trials.push({
          "trial_type": this.stim.trial_type, 
          "trial" : this.stim.trial,
          "adjective": adj,
          "response": 0,
          "rating": this.stim["rating"],
          "condition" : this.stim["condition"],
          "version" : this.stim["version"],
          "text" : this.stim["text"]
      });
    }
  }
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
  
  slides.auth = slide({
      "name": "auth",
      start: function() {

          $(".err").hide();
          // define possible speaker and listener names
          // fun fact: 10 most popular names for boys and girls
          var speaker = _.shuffle(["James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph", "Thomas", "Charles"])[0];
          var listener = _.shuffle(["Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", "Margaret"])[0];

          var story = speaker + ' says to ' + listener + ': "It\'s a beautiful day, isn\'t it?"'

          $("#check-story").text(story);
          $("#check-question").text("Who is " + speaker + " talking to?");
          this.trials = 0;
          this.listener = listener;

      },
      button: function() {
          this.trials++;
          $(".err").hide();
          resp = $("#check-input").val();
          if (resp.toLowerCase() == this.listener.toLowerCase()) {
              exp.go();
          } else {
              if (this.trials < 2) {
                  $("#check-error").show();
              } else {
                  $("#check-error-final").show();
                  $("#check-button").attr("disabled", "disabled");
              }
          }
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
  exp.structure=["i0", "auth", "instructions", "practice", "separator", "trial", "instructions_2", "trial_2", 'subj_info', 'thanks'];

  exp.data_trials = [];
  
  exp.data_part_1 = [];
  
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length() + exp.trials.length;
  $(".placeholder").each(function() {
    var key = $(this).text();
    $(this).text(TEMPLATE_DICT[key]);
  });
  
  $(".responses span").click(function() {
    $(this).toggleClass("active");
  });


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
