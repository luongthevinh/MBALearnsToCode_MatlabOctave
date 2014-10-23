function f = funcSoftmax_inputRowMat_n_biasWeightMat...
   (addBias = true)

   funcType = 'softmax';
   
   funcSignalVal = ...
      @(input_rowMat, biasWeight_Mat) ...
      addBiasElems(input_rowMat, addBias) ...
      * biasWeight_Mat;
   
   funcOutput_genDeriv = ...
      @(signalVal, returnDeriv = true) ...
      softmaxFunc_rowMat(signalVal, returnDeriv, 'gen');
      
   funcOutput_effDeriv = ...
      @(signalVal, returnDeriv = true) ...
      softmaxFunc_rowMat(signalVal, returnDeriv);
   
   funcOutputVal = ...
      @(input_rowMat, biasWeight_Mat, returnDeriv = true) ...
      funcOutput_effDeriv(funcSignalVal...
      (input_rowMat, biasWeight_Mat), returnDeriv).val;

   funcOutputOverSignalDeriv_genForm = ...
      @(input_rowMat, biasWeight_Mat) ...
      funcOutput_genDeriv(funcSignalVal...
      (input_rowMat, biasWeight_Mat)).deriv;
      
   funcOutputOverSignalDeriv_effForm = ...
      @(input_rowMat, biasWeight_Mat) ...
      funcOutput_effDeriv(funcSignalVal...
      (input_rowMat, biasWeight_Mat)).deriv;
   
   funcSignalOverInputDeriv = ...
      @(input_rowMat, biasWeight_Mat) ...
      linearOutputOverInputDeriv_rowMat...
      (rows(input_rowMat), ...
      rmBiasElems(biasWeight_Mat, addBias));
      
   funcSignalOverBiasWeightDeriv = ...
      @(input_rowMat, biasWeight_Mat) ...
      linearOutputOverWeightDeriv_rowMat...
      (columns(biasWeight_Mat), ...
      addBiasElems(input_rowMat, addBias));
      
   funcOutputOverInputDeriv = ...
      @(input_rowMat, biasWeight_Mat) ...
      arrProd...
      (funcOutputOverSignalDeriv_genForm...
      (input_rowMat, biasWeight_Mat), ...
      funcSignalOverInputDeriv...
      (input_rowMat, biasWeight_Mat), 2);

   funcOutputOverBiasWeightDeriv = ...
      @(input_rowMat, biasWeight_Mat) ...
      arrProd...
      (funcOutputOverSignalDeriv_genForm...
      (input_rowMat, biasWeight_Mat), ...
      funcSignalOverBiasWeightDeriv...
      (input_rowMat, biasWeight_Mat), 2);

   funcCostOverSignalGrad_thruCostOverOutputGrad = ...
      @(costOverOutputGrad, ...
      input_rowMat, biasWeight_Mat) ...
      costOverSignalGrad_thruCostOverOutputGrad_rowMat...
      (costOverOutputGrad, 'softmax', ...
      funcOutputOverSignalDeriv_effForm...
      (input_rowMat, biasWeight_Mat));
      
   funcCostOverInputGrad_thruCostOverOutputGrad = ...
      @(costOverOutputGrad, ...
      input_rowMat, biasWeight_Mat) ...
      funcCostOverSignalGrad_thruCostOverOutputGrad...
      (costOverOutputGrad, ...
      input_rowMat, biasWeight_Mat) ...
      * rmBiasElems(biasWeight_Mat, addBias)';

   funcCostOverBiasWeightGrad_thruCostOverOutputGrad = ...
      @(costOverOutputGrad, ...
      input_rowMat, biasWeight_Mat) ...
      addBiasElems(input_rowMat, addBias)' ...
      * funcCostOverSignalGrad_thruCostOverOutputGrad...
      (costOverOutputGrad, ...
      input_rowMat, biasWeight_Mat);
   
   f = defineTransformFunc_input_n_param...
      (funcType, addBias, ...
      funcSignalVal, funcOutputVal, ...
      funcOutputOverSignalDeriv_genForm, ...
      funcOutputOverSignalDeriv_effForm, ...
      funcSignalOverInputDeriv, ...
      funcSignalOverBiasWeightDeriv, ...
      funcOutputOverInputDeriv, ...
      funcOutputOverBiasWeightDeriv, ...
      funcCostOverSignalGrad_thruCostOverOutputGrad, ...
      funcCostOverInputGrad_thruCostOverOutputGrad, ...
      funcCostOverBiasWeightGrad_thruCostOverOutputGrad);
      
end