# Estimating parameters


1. Prepare data

- update prepare_data.R (in models/2_adaptation_model/scripts)
- make sure that percentage_middle is renamed to percentage_blue
- Example row in data:

    ```
    {"workerid":0,"rating2":0.89,"rating1":0.11,"catch_trial":0,"rating_other":0,"modal2":"probably","modal1":"might","percentage_blue":75,"pair":"might-probably","post_exposure":1,"reverse_sent_order":1,"catch_trial_answer_correct":-1,"color":"blue","speaker_cond":"f","condition":"cautious speaker","modal":"probably"}
    ```

2. Configure run

- Copy template directory and change file path in config file.

3. Run adaptation model

- Run this command from `2_adaptation_model` folder:

    ```
    python model/speaker_adaptation_full_data.py --out_dir explaining-away-runs/norming-bad-mood/ --run 1
    ```

4. Make predictions (hdi_interval.py)

- Run this command from `2_adaptation_model` folder:


    ```
    python model/hdi_interval.py --out_dir  explaining-away-runs/norming-bad-mood/ --filenames "run*_output.json"
    ```

- This will create a csv file called hdi_interval.csv.

5. Analysis

- Look at models/2_adaptation_model/full_data_runs_analysis.html
