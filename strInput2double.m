function varargout = strInput2double(varargin)
    varargin{1} = cell2mat(varargin{1});
    varargin{1}=strrep(varargin{1},'[','');
    varargin{1}= strrep(varargin{1},']','');
    varargin{1}= strsplit(varargin{1},varargin{2});
    if size(varargin,2)>2
        if strcmp(varargin{3},'BH')
            BHin = varargin{1}';
            for i = 1:size(varargin{1},2)                
                BHin{i}= str2double(strsplit(BHin{i},' '));                
            end
            varargin{1} = cell2mat(BHin);
            varargout{1} = varargin{1};
        end                
    else
        varargout{1} = str2double(varargin{1});
    end
end

