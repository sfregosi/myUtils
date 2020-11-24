function [horizontal vertical] = angcalc(bat,mikes)
bmv = mikes-ones(length(mikes(:,1)),1)*bat;
[horizontal h_r] = cart2pol(bmv(:,1),sign(bmv(:,2)).*sqrt(bmv(:,2).^2+bmv(:,3).^2));
[vertical v_r] = cart2pol(bmv(:,3),sign(bmv(:,2)).*sqrt(bmv(:,2).^2+bmv(:,1).^2));
