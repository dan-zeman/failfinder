var header = Array(
Array("systems","BLEUall","BLEUnw","BLEUweb","IBMall","IBMnw","IBMweb","NISTall","NISTnw","NISTweb","TERall","TERnw","TERweb","METEORall","METEORnw","METEORweb"),
Array("0","1","1","1","1","1","1","1","1","1","-1","-1","-1","1","1","1")
);
var orig_values = Array(
Array("CUED_a2e_cn_primary",0.4834,0.5641,0.3960,0.4833,0.5640,0.3959,11.01,11.31,9.603,0.4489,0.3861,0.5093,0.6570,0.7152,0.5999),
Array("LIUM-SYSTRAN_a2e_cn_contrast2_bugfix(1)(2)",0.4805,0.5669,0.3833,0.4804,0.5667,0.3831,11.04,11.44,9.456,0.4523,0.3831,0.5190,0.6539,0.7193,0.5892),
Array("isi-lw_a2e_cn_combo1",0.4802,0.5600,0.3914,0.4801,0.5598,0.3913,10.85,11.24,9.396,0.4643,0.3887,0.5371,0.6642,0.7319,0.5969),
Array("LIUM-SYSTRAN_a2e_cn_primary_bugfix(1)(2)",0.4790,0.5659,0.3807,0.4788,0.5658,0.3805,10.99,11.42,9.420,0.4564,0.3851,0.5253,0.6532,0.7191,0.5883),
Array("stanford_a2e_cn_contrast1",0.4786,0.5664,0.3849,0.4783,0.5660,0.3846,10.97,11.41,9.397,0.4417,0.3740,0.5069,0.6527,0.7164,0.5900),
Array("stanford_a2e_cn_primary",0.4781,0.5673,0.3843,0.4777,0.5668,0.3840,10.97,11.44,9.392,0.4399,0.3709,0.5065,0.6514,0.7153,0.5882),
Array("IBM_a2e_cn_combo0",0.4775,0.5636,0.3871,0.4773,0.5634,0.3870,11.03,11.54,9.466,0.4394,0.3713,0.5051,0.6526,0.7142,0.5924),
Array("LIUM-SYSTRAN_a2e_cn_primary",0.4773,0.5629,0.3800,0.4772,0.5627,0.3799,10.96,11.38,9.412,0.4565,0.3851,0.5252,0.6526,0.7185,0.5879),
Array("isi-lw_a2e_cn_primary",0.4763,0.5590,0.3810,0.4760,0.5588,0.3808,10.85,11.30,9.292,0.4590,0.3826,0.5328,0.6544,0.7233,0.5864),
Array("IBM_a2e_cn_combo1",0.4744,0.5634,0.3787,0.4742,0.5633,0.3785,11.00,11.54,9.281,0.4361,0.3713,0.4986,0.6491,0.7136,0.5853),
Array("IBM_a2e_constrained_primary",0.4708,0.5547,0.3833,0.4707,0.5545,0.3831,10.97,11.46,9.406,0.4424,0.3773,0.5051,0.6478,0.7091,0.5876),
Array("LIUM-SYSTRAN_a2e_cn_contrast1_bugfix(1)(2)",0.4702,0.5610,0.3686,0.4701,0.5608,0.3684,10.91,11.39,9.310,0.4587,0.3843,0.5304,0.6491,0.7165,0.5826),
Array("LIUM-SYSTRAN_a2e_cn_contrast1",0.4687,0.5578,0.3681,0.4686,0.5576,0.3680,10.89,11.34,9.304,0.4587,0.3844,0.5304,0.6485,0.7158,0.5822),
Array("BBN_a2e_cn_primary",0.4680,0.5566,0.3783,0.4678,0.5564,0.3781,10.85,11.46,9.304,0.4603,0.3800,0.5378,0.6561,0.7125,0.6015),
Array("IBM_a2e_cn_contrast1",0.4658,0.5512,0.3756,0.4657,0.5511,0.3755,10.90,11.40,9.300,0.4435,0.3784,0.5063,0.6435,0.7079,0.5801),
Array("SRI_a2e_cn_combo1",0.4631,0.5472,0.3731,0.4629,0.5470,0.3730,10.86,11.25,9.306,0.4592,0.3974,0.5189,0.6461,0.7063,0.5866),
Array("isi-lw_a2e_cn_contrast1",0.4630,0.5360,0.3748,0.4629,0.5358,0.3747,10.66,10.97,9.267,0.4811,0.4124,0.5474,0.6547,0.7215,0.5878),
Array("SRI_a2e_cn_combo2",0.4616,0.5472,0.3705,0.4615,0.5470,0.3705,10.88,11.25,9.374,0.4589,0.3974,0.5182,0.6476,0.7063,0.5900),
Array("FBK_a2e_cn_contrast2(1)",0.4570,0.5404,0.3628,0.4569,0.5403,0.3627,10.76,11.20,9.273,0.4718,0.3958,0.5452,0.6537,0.7171,0.5915),
Array("FBK_a2e_cn_primary",0.4567,0.5418,0.3615,0.4565,0.5417,0.3613,10.75,11.22,9.252,0.4721,0.3952,0.5462,0.6533,0.7170,0.5910),
Array("SAKHR_a2e_cn_contrast1",0.4551,0.5401,0.3678,0.4549,0.5400,0.3677,10.72,11.25,9.260,0.4637,0.3886,0.5362,0.6524,0.7018,0.6053),
Array("RWTH_a2e_cn_contrast1",0.4536,0.5439,0.3530,0.4535,0.5437,0.3529,10.69,11.20,9.033,0.4624,0.3928,0.5295,0.6512,0.7134,0.5896),
Array("RWTH_a2e_cn_primary",0.4534,0.5402,0.3538,0.4533,0.5400,0.3537,10.65,11.12,9.028,0.4666,0.3980,0.5328,0.6532,0.7154,0.5918),
Array("SRI_a2e_cn_primary",0.4527,0.5366,0.3634,0.4526,0.5365,0.3633,10.71,11.11,9.251,0.4689,0.4003,0.5351,0.6459,0.7071,0.5859),
Array("FBK_a2e_cn_contrast3(1)",0.4489,0.5279,0.3640,0.4488,0.5277,0.3638,10.64,11.06,9.237,0.4733,0.4050,0.5392,0.6492,0.7079,0.5919),
Array("Edinburgh_a2e_cn_primary",0.4479,0.5240,0.3605,0.4478,0.5238,0.3604,10.58,10.92,9.174,0.4857,0.4209,0.5482,0.6454,0.7069,0.5847),
Array("SRI_a2e_cn_contrast1",0.4462,0.5321,0.3561,0.4460,0.5319,0.3561,10.60,11.07,9.144,0.4786,0.4058,0.5488,0.6427,0.7018,0.5852),
Array("SRI_a2e_cn_contrast2",0.4428,0.5311,0.3502,0.4428,0.5310,0.3501,10.62,11.14,9.087,0.4711,0.3999,0.5397,0.6408,0.7011,0.5819),
Array("UMD_a2e_cn_primary",0.4409,0.5340,0.3415,0.4408,0.5338,0.3413,10.53,11.25,8.590,0.4591,0.3909,0.5248,0.6287,0.6982,0.5595),
Array("JHU_a2e_cn_primary(1)",0.4409,0.5225,0.3526,0.4408,0.5225,0.3524,10.62,11.05,9.108,0.4725,0.4100,0.5328,0.6428,0.7062,0.5801),
Array("UMD_a2e_cn_contrast1",0.4385,0.5311,0.3394,0.4384,0.5310,0.3393,10.59,11.28,8.706,0.4570,0.3863,0.5252,0.6325,0.7030,0.5624),
Array("LIMSI_Moses_a2e_cn_primary",0.4384,0.5242,0.3471,0.4383,0.5240,0.3469,10.40,10.98,8.738,0.4724,0.4051,0.5373,0.6212,0.6851,0.5582),
Array("IBM_a2e_cn_contrast2",0.4363,0.5253,0.3410,0.4361,0.5250,0.3408,10.60,11.12,9.020,0.4677,0.3991,0.5338,0.6419,0.7059,0.5786),
Array("SRI_a2e_cn_contrast3",0.4335,0.5181,0.3457,0.4334,0.5180,0.3456,10.42,10.94,8.985,0.4887,0.4192,0.5557,0.6327,0.6885,0.5787),
Array("CMU-SMT_a2e_cn_primary",0.4304,0.5055,0.3473,0.4302,0.5053,0.3469,10.33,10.72,8.896,0.4823,0.4182,0.5442,0.6365,0.6988,0.5748),
Array("IBM_a2e_cn_contrast3",0.4289,0.5145,0.3377,0.4286,0.5142,0.3373,10.37,10.93,8.758,0.4736,0.4087,0.5362,0.6292,0.6919,0.5676),
Array("CMU-SMT_a2e_cn_contrast2",0.4287,0.5082,0.3461,0.4285,0.5080,0.3460,10.21,10.77,8.695,0.4972,0.4177,0.5738,0.6266,0.6903,0.5629),
Array("LIMSI_Moses+Ncode_a2e_cn_contrast2",0.4264,0.5242,0.3248,0.4262,0.5240,0.3246,10.33,10.98,8.744,0.4861,0.4051,0.5643,0.6233,0.6851,0.5629),
Array("CMU-SMT_a2e_cn_contrast1",0.4247,0.4966,0.3410,0.4244,0.4963,0.3407,10.29,10.58,8.915,0.4832,0.4254,0.5389,0.6398,0.7009,0.5793),
Array("FBK_a2e_cn_contrast1",0.4231,0.5020,0.3349,0.4229,0.5019,0.3347,10.07,10.50,8.678,0.4964,0.4239,0.5663,0.6533,0.7170,0.5910),
Array("UvA_a2e_cn_primarydebug(1)(2)",0.4221,0.5087,0.3294,0.4220,0.5086,0.3293,10.31,10.88,8.512,0.4817,0.4170,0.5441,0.6257,0.6930,0.5584),
Array("isi-lw_a2e_cn_contrast2",0.4200,0.4860,0.3434,0.4198,0.4858,0.3432,10.16,10.43,8.936,0.5157,0.4500,0.5790,0.6395,0.7003,0.5790),
Array("columbia_a2e_cn_primary",0.4157,0.4932,0.3331,0.4156,0.4931,0.3330,10.27,10.73,8.785,0.4747,0.4160,0.5313,0.6269,0.6847,0.5698),
Array("LIMSI_Ncode_a2e_cn_contrast1",0.4116,0.4943,0.3248,0.4115,0.4943,0.3246,10.22,10.72,8.744,0.4953,0.4237,0.5643,0.6250,0.6882,0.5629),
Array("TUBITAK_a2e_cn_primary",0.4112,0.4826,0.3310,0.4121,0.4827,0.3312,10.01,10.43,8.659,0.5129,0.4445,0.5789,0.6259,0.6890,0.5627),
Array("CMU-Stat-Xfer_a2e_cn_primary",0.3774,0.4448,0.2986,0.3772,0.4447,0.2984,9.731,10.07,8.399,0.5158,0.4628,0.5669,0.6082,0.6684,0.5484),
Array("SAKHR_a2e_cn_primary",0.3681,0.4185,0.3147,0.3680,0.4184,0.3147,9.867,9.982,8.887,0.5075,0.4626,0.5508,0.6320,0.6737,0.5913),
Array("UPC.LSI_a2e_cn_primary",0.3588,0.4344,0.2778,0.3588,0.4345,0.2777,9.404,10.05,7.655,0.5188,0.4630,0.5725,0.5866,0.6515,0.5216),
Array("UvA_a2e_cn_primary",0.3221,0.3820,0.2565,0.3218,0.3816,0.2563,8.621,9.063,7.458,0.5995,0.5437,0.6533,0.5863,0.6457,0.5278),
Array("KCSL_a2e_cn_primary",0.1422,0.1670,0.1161,0.1420,0.1669,0.1158,6.647,6.959,5.820,0.6590,0.6353,0.6818,0.4937,0.5398,0.4482),
Array("TLVEBMT_a2e_cn_primary",0.0703,0.0872,0.0527,0.0703,0.0872,0.0526,3.879,4.370,3.165,0.7483,0.7274,0.7685,0.3853,0.4262,0.3450)
);
