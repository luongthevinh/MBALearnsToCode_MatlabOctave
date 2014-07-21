function results = zzzTest_ffNN_gradChk...
   (numRuns = 1, ffNN = {}, ...
   perturb = 1e-6, prec = 1e-6)
  
   % PARAMETERS
   % ----------
   maxNumCases = 3;
   maxNumLayersExclInput = 3;
   maxNumNodesPerLayer = 3;
   maxNumInputClasses = 3;
   maxNumInputEmbedFeatures = 3;
   inputMagnOrder = 1e1;
   initParamMagnOrder = 1e-1;

   succsAbs = 0; failsAbs = [];
   succsRel = 0; failsRel = [];

   fprintf('\nPertubance Size = %g\n', perturb);
   fprintf('Avg Precision Tested For = %g\n', prec);   
   
   for (r = 1 : numRuns)

      fprintf('\rTest no.: %i', r);

      % SET featEmbed & regulParam
      % --------------------------
      featEmbed = randElem([true false]);
      regulParam = randElem(const_regulParams_10);

      % SET MODEL STRUCTURE
      % -------------------
      if isempty(ffNN)
      
         numsNodes(1) = nI = unidrnd(maxNumNodesPerLayer);
         transformFuncs = paramDimSizes = {};
         
         if (featEmbed)
         
            nC = unidrnd(maxNumInputClasses);
            nF = unidrnd(maxNumInputEmbedFeatures);
            paramDimSizes{1} = [nC nF];
            transformFuncs{1} = ...
               funcEmbedClassIndcs_inRealFeats_rowMat;
            numsNodes(2) = nI * nF;
            
         else
         
            numsNodes(2) = unidrnd(maxNumNodesPerLayer);
            addBias = rand > 0.5;
            paramDimSizes{1} = ...
               [(numsNodes(1) + addBias) numsNodes(2)];
            transformFuncs{1} = randElem...
      ({funcLinear_inputRowMat_n_biasWeightMat(addBias) ...
      funcLogistic_inputRowMat_n_biasWeightMat(addBias) ...
      funcSoftmax_inputRowMat_n_biasWeightMat(addBias)});
          
         endif
         
         for (k = 2 : (1 + unidrnd(maxNumLayersExclInput)))
         
            numsNodes(k + 1) = unidrnd(maxNumNodesPerLayer);
            addBias = rand > 0.5;
            paramDimSizes{k} = ...
               [(numsNodes(k) + addBias) numsNodes(k + 1)];
            transformFuncs{k} = randElem...
      ({funcLinear_inputRowMat_n_biasWeightMat(addBias) ...
      funcLogistic_inputRowMat_n_biasWeightMat(addBias) ...
      funcSoftmax_inputRowMat_n_biasWeightMat(addBias)});
               
         endfor
         
         NN = ffNN_new(nI, paramDimSizes, transformFuncs, ...
            false, true, initParamMagnOrder);
         m = unidrnd(maxNumCases);
         
         if (featEmbed)
            input_Arr = tests{r}.input_Arr = ...
               unidrnd(nC, [m nI]);
            NN.params{1} *= 1 ...
               * inputMagnOrder / initParamMagnOrder;
         else
            input_Arr = tests{r}.input_Arr = ...
               randUnif([m nI], inputMagnOrder);
         endif
         
      else
      
         NN = ffNN;
         m = unidrnd(maxNumCases);
         inputDimSizes_perCase = NN.inputDimSizes_perCase;
         input_Arr = tests{r}.input_Arr = ...
            randUnif([m inputDimSizes_perCase], ...
            inputMagnOrder);        
         
      endif  
   
      % RANDOMIZE TARGET OUTPUT 
      % -----------------------      
      nO = NN.paramDimSizes{NN.numLayers}(2);
      if strcmp(NN.costFuncType, 'CE-S')
         targetOutput_rowMat = ...
            tests{r}.targetOutput_rowMat = ...
            predictClass_rowMat(rand([m nO]));
      else
         targetOutput_rowMat = ...
            tests{r}.targetOutput_rowMat = ...
            randUnif([m nO]) > 0;
      endif
       
      % COMPUTE ANALYTIC GRADIENTS
      % --------------------------
      NN = ffNN_fProp_bProp...
         (input_Arr, NN, targetOutput_rowMat, regulParam);
      tests{r}.ffNN = NN;
      
      if (featEmbed)
         aGrad = tests{r}.aGrad = convertArrsToColVec...
            (NN.paramGrads);
      else
         aGrad = tests{r}.aGrad = convertArrsToColVec...
            ([NN.activGrads{1} NN.paramGrads]);
      endif

      % COMPUTE NUMERICAL GRADIENTS
      % ---------------------------
      if (featEmbed)
         costAvgFunc = ...
            @(p_v) ffNN_costWRegul_n_inputGrad_n_paramGrads...
            ([input_Arr(:); p_v], NN, targetOutput_rowMat, ...
             regulParam, false);

         nGrad = tests{r}.nGrad = gradApprox(costAvgFunc, ...
            convertArrsToColVec(NN.params), perturb);     
      else
         costAvgFunc = ...
            @(ip_v) ffNN_costWRegul_n_inputGrad_n_paramGrads...
            (ip_v, NN, targetOutput_rowMat, regulParam);
         nGrad = tests{r}.nGrad = gradApprox(costAvgFunc, ...
            convertArrsToColVec([input_Arr NN.params]), ...
            perturb);
      endif

      % COMPARE GRADIENTS  
      % -----------------
      tests{r}.gradAbsEqTest = ...
         equalTest(nGrad, aGrad, prec, 'abs');
      
      [tests{r}.gradRelEqTest tests{r}.gradRelD ...
      tests{r}.gradAvgAbsD tests{r}.gradMaxAbsD] = ...
         equalTest(nGrad, aGrad, prec);

      if tests{r}.gradAbsEqTest 
         succsAbs++;    
      else
         failsAbs = [failsAbs r];     
      endif

      if tests{r}.gradRelEqTest
         succsRel++;
      else
         failsRel = [failsRel r]; 
      endif

   endfor

   results.numRuns = numRuns;
   results.tests = tests;
   results.succsAbsPct = succsAbs / numRuns * 100;
   results.failsAbs = failsAbs;
   results.succsRelPct = succsRel / numRuns * 100;
   results.failsRel = failsRel;

   fprintf('\n\nAbsolute Comparison Success Percent: %g\n', results.succsAbsPct);
   fprintf('   abs fails:\n');

   for i = failsAbs
      fprintf(' %i (%g)', i, tests{i}.gradAvgAbsD);
   endfor

   fprintf('\n\nRelative Comparison Success Percent: %g\n', results.succsRelPct);
   fprintf('   rel fails:\n');

   for i = failsRel
      fprintf(' %i (%g)', i, tests{i}.gradRelD);
   endfor

   fprintf('\n\n');
   
end