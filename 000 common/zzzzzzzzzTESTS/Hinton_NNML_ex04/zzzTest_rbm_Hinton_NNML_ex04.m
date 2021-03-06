function zzzTest_rbm_Hinton_NNML_ex04...
   (numEpochs = 100, numHid = 300, learningRate = 0.02, ...
   plotLearningCurves = false)

   a4_init;
   rbm = class_rbm(100, 256, ...
      'logisticNoBias', 'logisticNoBias', 1, true, false);
   rbm.weights = test_rbm_w;

   fprintf('QUESTION 2:\n');
   vis = data_1_case';
   hid = updateLayer(rbm, 'hid', vis, false, ...
      true, randomness_source);
   describe_matrix(hid);
   vis = data_10_cases';
   hid = updateLayer(rbm, 'hid', vis, false, ...
      true, randomness_source);
   describe_matrix(hid);
   vis = data_37_cases';
   hid = updateLayer(rbm, 'hid', vis, false, ...
   true, randomness_source);
   describe_matrix(hid);
   fprintf('\n');

   fprintf('QUESTION 3:\n');
   hid = test_hidden_state_1_case';
   vis = updateLayer(rbm, 'vis', hid, false, ...
      true, randomness_source);
   describe_matrix(vis);
   hid = test_hidden_state_10_cases';
   vis = updateLayer(rbm, 'vis', hid, false, ...
      true, randomness_source);
   describe_matrix(vis);
   hid = test_hidden_state_37_cases';
   vis = updateLayer(rbm, 'vis', hid, false, ...
      true, randomness_source);
   describe_matrix(vis);
   fprintf('\n');

   fprintf('QUESTION 4:\n');
   hid = test_hidden_state_1_case';
   vis = data_1_case';
   g = goodnessAvg(rbm, hid, vis)
   hid = test_hidden_state_10_cases';
   vis = data_10_cases';
   g = goodnessAvg(rbm, hid, vis)
   hid = test_hidden_state_37_cases';
   vis = data_37_cases';
   g = goodnessAvg(rbm, hid, vis)
   fprintf('\n');

   fprintf('QUESTION 6:\n');
   vis = data_1_case';
   weightGrad = contrastiveDivergence...
      (rbm, vis, 1, true, true, randomness_source);
   describe_matrix(weightGrad);
   vis = data_10_cases';
   weightGrad = contrastiveDivergence...
      (rbm, vis, 1, true, true, randomness_source);
   describe_matrix(weightGrad);
   vis = data_37_cases';
   weightGrad = contrastiveDivergence...
      (rbm, vis, 1, true, true, randomness_source);
   describe_matrix(weightGrad);
   fprintf('\n');

   fprintf('QUESTION 7:\n');
   vis = data_1_case';
   weightGrad = contrastiveDivergence...
      (rbm, vis, 1, false, true, randomness_source);
   describe_matrix(weightGrad);
   vis = data_10_cases';
   weightGrad = contrastiveDivergence...
      (rbm, vis, 1, false, true, randomness_source);
   describe_matrix(weightGrad);
   vis = data_37_cases';
   weightGrad = contrastiveDivergence...
      (rbm, vis, 1, false, true, randomness_source);
   describe_matrix(weightGrad);
   fprintf('\n');

   fprintf('QUESTION 8:\n');
   tic;
   rbm_Hinton = optimize([numHid, 256], ...
      @(rbm_w, data) cd1(rbm_w, data.inputs), ...  % discard labels
      data_sets.training, learningRate, 10 * numEpochs);
   fprintf('Hinton''s trained RBM after %is:\n', toc); 
   describe_matrix(rbm_Hinton);
      
   rbm = class_rbm(numHid, 256, ...
      'logisticNoBias', 'logisticNoBias', 1, false, false);
   tic;
   rbm.weights = (a4_rand([numHid, 256], 256 * numHid) ...
      * 2 - 1) * 0.1;
   trainData = data_sets.training.inputs';
   
   rbm = train_gradAsc...
      (rbm_init___ = rbm, ...
      dataArgs___ = {trainData}, ...   
      trainNumsEpochs___ = numEpochs, ...
      cd_chainLengths___ = 1, ...   
      trainBatchSize___ = 100, ...
      trainRandShuff___ = false, ...
      trainGoodnessApproxChunk_numBatches___ = 1, ...
      validGoodnessCalcInterval_numChunks___ = 1, ...
      learningRate___ = learningRate, ...
      momentumRate___ = 9e-1, ...
      nesterovAccGrad___ = false, ...
      weightRegulArgs___ = {'L2' 0}, ...
      bestStop___ = false, ...
      saveFileName___ = 'rbm_trained.mat', ...
      saveEvery_numMins___ = 3, ...
      plotLearningCurves___ = plotLearningCurves, ...
      batchDim = 3, ...
      immedWeightChangesMemory_init___ = [], ...   
      useRandSource___ = true, ...
      randSource_Mat___ = randomness_source);
   
   fprintf('Package-trained RBM after %is:\n', toc);
   describe_matrix(rbm.weights);

endfunction