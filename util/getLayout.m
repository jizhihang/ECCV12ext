function fields = getLayout(Polyg, w, h)
    fields=zeros(h,w);
    %1 floor
    polyg=Polyg{1};
    if numel(polyg)>0
        tempimg1=poly2mask(polyg(:,1),polyg(:,2),h,w);
    else
        tempimg1=zeros(h,w);
    end
    fields=fields.*(fields~=0)+1*tempimg1.*(fields==0);

    %2 middlewall

    polyg=Polyg{2};
    if numel(polyg)>0
        tempimg1=poly2mask(polyg(:,1),polyg(:,2),h,w);
    else
        tempimg1=zeros(h,w);
    end
    fields=fields.*(fields~=0)+2*tempimg1.*(fields==0);
    %3 right wall

    polyg=Polyg{3};
    if numel(polyg)>0
        tempimg1=poly2mask(polyg(:,1),polyg(:,2),h,w);
    else
        tempimg1=zeros(h,w);
    end
    fields=fields.*(fields~=0)+3*tempimg1.*(fields==0);
    %4 left wall

    polyg=Polyg{4};
    if numel(polyg)>0
        tempimg1=poly2mask(polyg(:,1),polyg(:,2),h,w);
    else
        tempimg1=zeros(h,w);
    end
    fields=fields.*(fields~=0)+4*tempimg1.*(fields==0);
    %
    %5 ceiling

    polyg=Polyg{5};
    if numel(polyg)>0
        tempimg1=poly2mask(polyg(:,1),polyg(:,2),h,w);
    else
        tempimg1=zeros(h,w);
    end
    fields=fields.*(fields~=0)+5*tempimg1.*(fields==0);

    fields = fields.*(fields~=0) + 6*(fields==0);
end