getgenv()['returnal'] = {
    ['camlock'] = {
        ['Key'] = 'Q';               -- Key to toggle the lock
        ['ShakeValue'] = 0.9;        -- Camera shake intensity
        ['ClosestPart'] = true;      -- Lock to the closest part (e.g., head)
        ['Air'] = {
            ['AirPart'] = 'Head';    -- Focus on the head when the player is in the air (jumping)
            ['UseAirPart'] = true;  -- Whether to use AirPart locking
        };
        ['CustomParts'] = {
            ['Enabled'] = true;     -- Whether to enable custom parts locking
            ['Parts'] = 'Head';     -- Default part to lock to (e.g., 'Head')
        };
        ['Adjusting'] = {
            ['Smoothing'] = 0.1;    -- Camera smoothing value
        };
        ['Advance'] = {
            ['PredictionY'] = 0.2;  -- Prediction value for Y-axis (can adjust based on ping)
            ['PredictionX'] = 0.2;  -- Prediction value for X-axis
        };
    };
}
