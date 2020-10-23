%% Prepare Matrices

path = 'Ecoinvent - cut-off system model\universal_matrix_export_3.6_cut-off\';
A_raw = readtable([path 'A_public.csv']);
B_raw = readtable([path 'B_public.csv']);
Q_raw = readtable([path 'C.csv']);
A = sparse(A_raw.row+1,A_raw.column+1,A_raw.coefficient);
Bt = sparse(B_raw.row+1,B_raw.column+1,B_raw.coefficient);
B = zeros(size(Bt,1), length(A));
B(1:size(Bt,1),1:size(Bt,2)) = Bt;
Q = sparse(Q_raw.row+1,Q_raw.column+1,Q_raw.coefficient);
%ee = readtable([path 'ee_index.csv']); % not needed
ie = readtable([path 'ie_index.csv']);
ee = readtable([path 'ee_index.csv']);
LCIA = readtable([path 'LCIA_index.csv']);
A_min = A-eye(length(A));
A_inv = inv(A);
C = Q*B*A_inv;

% Exchange Matrices

save('LCD/LciMat.mat','A_inv','A_min','B','C','Q','ie','ee','LCIA','-v7.3');

