switch P.method
    case 'pre'
        disp('Detection mode: Preprocess');
        P.detection_flag = 1;
        P.pre_flag = 1;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 0;
        P.robustness_flag = 0;
        P.grasp_flag = 0;
        P.ccw_flag = 0;
    case 'sw'
        disp('Detection mode: Sliding Window');
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 1;
        P.discriminative_flag = 0; 
        P.detectorimprove_supervision = 0;
        P.discriminative_detection_mode = 2;
        P.bblock_flag = 0;
        P.robustness_flag = 0;        
        P.discriminative_detection_mode = 2;
        P.grasp_flag = 0;
        P.ccw_flag = 0;
    case 'dl'
        disp('Detection mode: Discriminative Learning');       
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 1;
        P.discriminative_flag = 1; 
        P.detectorimprove_supervision = 0;
        P.discriminative_detection_mode = 5;
        P.bblock_flag = 0;
        P.robustness_flag = 0;     
        P.grasp_flag = 0;
        P.ccw_flag = 0;
    case 'bb' 
        disp('Detection mode: Building Blocks');
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 1;
        P.bblock_nodl_flag = 0;
        P.robustness_flag = 0;  
        P.grasp_flag = 0;
        P.gm_flag = 0;
        P.ccw_flag = 0;
    case 'gmbb'
        disp('Detection mode: Building Blocks');
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 1;
        P.bblock_nodl_flag = 0;
        P.robustness_flag = 0;  
        P.grasp_flag = 0;        
        P.gm_flag = 1;
        P.ccw_flag = 0;
    case 'nodlbb'
        disp('Detection mode: Building Blocks without discriminative learning');
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 1;
        P.bblock_nodl_flag = 1;
        P.robustness_flag = 0;
        P.grasp_flag = 0;
        P.gm_flag = 0;
        P.ccw_flag = 0;
    case 'rob'
        disp('Detection mode: Robustness Analysis')
        P.detection_flag = 0;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 0;
        P.robustness_flag = 1;    
        P.grasp_flag = 0;
        P.ccw_flag = 0;
    case 'sws'
        disp('Detection mode: Sliding Window (Supervised)')
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 1;
        P.discriminative_flag = 0; 
        P.detectorimprove_supervision = 1;
        P.discriminative_detection_mode = 2;
        P.bblock_flag = 0;
        P.robustness_flag = 1;   
        P.grasp_flag = 0;
        P.discriminative_supervision = 1;
        P.discriminative_detection_mode = 2;
        P.ccw_flag = 0;
    case 'hoge'
        disp('Detection mode: HoG Embedding')
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 1;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 0;
        P.robustness_flag = 0;         
        P.grasp_flag = 0;
        P.ccw_flag = 0;
    case 'sfe'
        disp('Detection mode: Symmetry Factor Embedding')
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 1;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 0;
        P.robustness_flag = 0;
        P.grasp_flag = 0;
        P.ccw_flag = 0;
    case 'ccw'
        disp('Detection mode: CCW')
        P.detection_flag = 0;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 0;
        P.robustness_flag = 0;
        P.grasp_flag = 0;
        P.ccw_flag = 1;
    case 'grasp'
        disp('Detection mode: Grasp')
        P.detection_flag = 1;
        P.pre_flag = 0;
        P.sfe_flag = 0;
        P.hoge_flag = 0;
        P.detectorimprove_flag = 0;
        P.bblock_flag = 0;
        P.robustness_flag = 0;      
        P.grasp_flag = 1;
        P.ccw_flag = 0;
    otherwise
        warning('Unexpected methods.');
end


