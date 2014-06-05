function f = evalClassif...
   (predClasses_Arr, targetClasses_Arr, detectBin = true)
   
   predClasses_no0_colVec = ...
      convertBinClassIndcs(predClasses_Arr(:), 0, 2);
   targetClasses_no0_colVec = ...
      convertBinClassIndcs(targetClasses_Arr(:), 0, 2); 
   K = f.numClasses = numClasses = ...
      max([predClasses_no0_colVec; targetClasses_no0_colVec]);
   f.numElems = numElems = ...
      length(targetClasses_no0_colVec);
      
   confusionMat = zeros(numClasses);
   for (i = 1 : numClasses)
      for (j = 1 : numClasses)
         confusionMat(i, j) = ...
            sum((predClasses_no0_colVec == i) ...
            & (targetClasses_no0_colVec == j));
      endfor
   endfor
   f.confusionMat = confusionMat;
   
   if (numClasses == 2) && detectBin
      K = 1;
   endif
   
   for (k = 1 : K)
   
      f.numPos(k) = numPos = ...
         sum(confusionMat(:, k));
      f.numNeg(k) = numNeg = ...
         numElems - numPos;
      f.numPredPos(k) = numPredPos = ...
         sum(confusionMat(k, :));
      f.numPredNeg(k) = numPredNeg = ...
         numElems - numPredPos;
      f.numTPos(k) = numTPos = ...
         confusionMat(k, k);
      f.numFPos(k) = numFPos = ...
         numPredPos - numTPos;
      f.numFNeg(k) = numFNeg = ...
         numPos - numTPos;
      f.numTNeg(k) = numTNeg = ...
         numNeg - numFPos;
         
      f.precision(k) = precision = ...
         numTPos / numPredPos;
      f.recall(k) = recall = ...
         numTPos / numPos;
      f.specificity(k) = specificity = ...
         numTNeg / numNeg;
      f.negPredVal(k) = negPredVal = ...
         numTNeg / numPredNeg;
      f.fallOut(k) = fallOut = ...
         1 - specificity;
      f.falseDiscov(k) = falseDiscov = ...
         1 - precision;
      f.miss(k) = miss = ...
         1 - recall;
      f.diagnLikelihood_pos = diagnLikelihood_pos = ...
         recall / (1 - specificity);
      f.diagnLikelihood_neg = diagnLikelihood_neg = ...
         (1 - recall) / specificity;
   
      f.accuracy(k) = accuracy = ...
         (numTPos + numTNeg) / numElems;
      f.f1score(k) = f1score = ...
         mean([precision recall], 'h');   
      f.MatthewsCorr(k) = MatthewsCorr = ...
         (numTPos * numTNeg - numFPos * numFNeg) ...
         / sqrt(numPos * numNeg * numPredPos * numPredNeg);
      f.informedness(k) = informedness = ...
         recall + specificity - 1;
      f.markedness(k) = markedness = ...
         precision + negPredVal - 1;
      f.balSucc = balSucc = ...
         (recall + specificity) / 2;
      f.balErr = balErr = ...
         1 - balSucc;
     
   endfor   
   
end