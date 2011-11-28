function [elem] = subsref(tt,s)
%[ELEM]=SUBSREF(TT,S)
%Used to evaluate element of a tensor,
%and also --- get fields D,R,N,PS,CORE of the TT tensor

switch s(1).type    
    case '()'
	  %Evaluate element of a tensor in position s
      d=tt.d; n=tt.n; ps=tt.ps; cr=tt.core; r=tt.r;
      %ind=double(s);
      pp=s.subs;
      mn=numel(pp); 
      if ( mn < d && mn > 1 || (mn == 1 && numel(pp{1}) < d) ) 
        error('Invalid number of indices specified: given %d, need %d \n',mn,d);
      end
      if ( mn == 1 ) %Special case
         ind=pp{1};
         if ( isa(ind,'double') )
           for i=1:d
             pp{i}=ind(i);
           end
         else
            pp=ind; %Supposedly it was a cell array of index subsets  
         end
      end
      elem=tt_tensor;
      elem.r=r; 
      elem.d=d;
      n0=zeros(d,1);
      for i=1:d
        ind=pp{i};
        if ( ind == ':')
            pp{i}=1:n(i);
            ind=pp{i};
        end
        n0(i)=numel(ind);
      end
      ps1=cumsum([1;n0.*r(1:d).*r(2:d+1)]);
      cr1=zeros(ps1(d+1)-1,1);
      for i=1:d
         ind=pp{i}; 
         crx=cr(ps(i):ps(i+1)-1);
         crx=reshape(crx,[r(i),n(i),r(i+1)]);
         crx=crx(:,ind,:);
         cr1(ps1(i):ps1(i+1)-1)=crx(:);          
      end
      if ( prod(n0) == 1 ) %single element
         v=1;
         for i=1:d
            crx=cr1(ps1(i):ps1(i+1)-1); crx=reshape(crx,[r(i),r(i+1)]);
            v=v*crx;
         end
         elem=v;
      else
         elem.n=n0;
         elem.core=cr1;
         elem.ps=ps1;
         
      end
    case '.'
        switch s(1).subs
            case 'core'
                elem = tt.core;
                if (numel(s)>1)
                    s = s(2:end);
                    elem = subsref(elem, s);
                end;                
            case 'tuck'
                elem = tt.tuck;
                if (numel(s)>1)
                    s = s(2:end);
                    elem = subsref(elem, s);
                end;
            case 'd'
                elem = tt.dphys;
            case 'dphys'
                elem = tt.dphys;
            case 'sz'
                elem = tt.sz;
                if (numel(s)>1)
                    s = s(2:end);
                    elem = subsref(elem, s);
                end;              
            otherwise
                error(['No field ', s.subs, ' is here.']);
        end
    case '{}'
%         %Return the core in the old (not exactly!!! r1-n-r2 here) format
        elem = subsref(tt.tuck, s);
%         pp=s.subs;
%         mn=numel(pp);
%         if ( mn > 1 )
%           error('Invalid number of cores asked');
%         end
%         elem=core(tt,pp{1});
% %         if (pp{1}~=1)
% %             elem=permute(elem,[2,1,3]);
% %         end;
        
    otherwise        
        error('Invalid subsref.');
end
