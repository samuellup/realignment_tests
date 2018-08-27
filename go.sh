sleep 5h

mv ../sra/*.gz ./user_data/
gunzip ./user_data/*.gz 


( ./workflow-realigner.sh sca_nore ler.fa pe none ) &

./workflow-realigner.sh sca_re ler.fa pe none realign