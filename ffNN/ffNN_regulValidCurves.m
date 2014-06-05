function f = ffNN_regulValidCurves(regulParams_vec, ffNN, ...
   trainInput_rowMat, trainTargetOutput_rowMat, ...
   validInput_rowMat, validTargetOutput_rowMat, ...
   maxNumIters, funcOptimMethod = @fmincg, ...
   initSigma = 1e-2, randInit = true)

   for (i = 1 : length(regulParams_vec))

      ffNN_trained = ffNN_train...
         (trainInput_rowMat, ffNN, ...
         trainTargetOutput_rowMat, maxNumIters, ...
         regulParams_vec(i), {}, false, ...
         funcOptimMethod, initSigma, randInit);

      f.trainCostAvg_noRegul(i) = ...
         ffNN_trained.costAvg_noRegul;

      f.validCostAvg_noRegul(i) = ffNN_fProp_bProp...
         (validInput_rowMat, ffNN_trained, ...
         validTargetOutput_rowMat, 0, false).costAvg_noRegul;

   endfor

end