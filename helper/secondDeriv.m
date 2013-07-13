function Db = secondDeriv(N)

Db = zeros(N);
Db = Db + diag(ones(1,N)*2);
Db = Db + diag(ones(1,N-1)*-1,1);
Db = Db + diag(ones(1,N-1)*-1,-1);
Db(1,1) = 1;
Db(end,end) = 1;
Db = sparse(Db);