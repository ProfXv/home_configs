#!/usr/bin/env -S awk -f

BEGIN {
    FS = "\t"
    for(i=0; i<=9; i++) {
        key_var = "GEMINI_API_KEY_" i
        if (ENVIRON[key_var] != "") {
            key_map[ENVIRON[key_var]] = i
        }
    }
}

{
    api_key = $1
    model = $2
    prompt_token = $3
    candidates_token = $4
    total_token = $5

    if (api_key in key_map) {
        idx = key_map[api_key]
        if (index(model, "pro") > 0) {
            pro_sum[idx]++
            pro_prompt_token[idx] += prompt_token
            pro_candidates_token[idx] += candidates_token
            pro_total_token[idx] += total_token
        } else {
            flash_sum[idx]++
            flash_prompt_token[idx] += prompt_token
            flash_candidates_token[idx] += candidates_token
            flash_total_token[idx] += total_token
        }
    }
}

END {
    for (i = 0; i <= 9; i++) {
        printf("%d\t%s\t%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\t%d\n",
               i,
               "gemini-2.5-pro",
               pro_sum[i],
               pro_prompt_token[i],
               pro_candidates_token[i],
               pro_total_token[i],
               "gemini-2.5-flash",
               flash_sum[i],
               flash_prompt_token[i],
               flash_candidates_token[i],
               flash_total_token[i])
    }
}
