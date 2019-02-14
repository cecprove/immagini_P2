%% P2
% crea database
imagespath=dir('C:\Users\cecil\Documents\Universita\ElaborazioneImmagini\Progetto\Database_per_gli_elaborati_di_Tipo_2_20190202\Yale\Yale');
imagespath;
ImagesPath=imagespath(4:end,:);% Per eliminare i primi tre elementi che non sono immagini
images=struct;

for i=1:size(ImagesPath,1)
    images(i).images=imread([ImagesPath(i).folder,'/',ImagesPath(i).name]);
    % creo il path totale dell'immagine, quindi
    % sto caricando con ogni ciclo la struttura ad ogni immagine
    % Se volessi solo l'immagine 7 scriverò images(7).images e gli dico di
    % andare a prendere la settima immagine che ha  caricato nel database, in
    % questo caso la struct
    %creo struct con tuttii nomi delle immagini
    images(i).tipologia = extractAfter(ImagesPath(i).name,".");
end

%% Associamo ad ogni etichetta un numero
for i=1:size(images,2)
    switch images(i).tipologia
        case 'glasses'
           images(i).etichetta = 1; 
        case 'happy'
            images(i).etichetta = 2;
        case 'leftlight'
            images(i).etichetta = 3;
        case 'noglasses'
            images(i).etichetta = 4;
        case 'normal'
            images(i).etichetta = 5;
        case 'rightlight'
            images(i).etichetta = 6;
        case 'sad'
            images(i).etichetta = 7;
        case 'sleepy'
            images(i).etichetta = 8;
        case 'surprised'
            images(i).etichetta = 9;
        case 'wink'
            images(i).etichetta = 10;
        case 'centerlight'
            images(i).etichetta = 11;
                  
    end
            
end

%% creiamo le HOG feature di tutte le immagini
% creo la struttura database.condizione(a).feature(b).matrice.matrice 
% a= 1--> senza rumore e a=2,3,4,5 rumore crescente
% b= 1,2 e 3 son le varie CellSize


% dobbiamo far variare con un ciclo for a da 1 a 5 per i vari livelli di
% rumore
c=[2 4 8];
rumore = logspace(-5,-1,5);
for a=1:5 
   for b=1:3
          for i=1:size(images,2)
           [database.condizione(a).feature(b).matrice(i).matrice,visualization] = extractHOGFeatures((double(images(i).images)+sqrt(rumore(a))*randn(size(images(i).images))), ...
               'CellSize',[c(b) c(b)]);
          end          
    
   end
end

%prova
%imshow(database.dimensione.dominio(1).immagini(2).matrice(11).matrice);
%hold on
%plot(visualization)

%% Logica leave one out
v=1:size(images,2);
for a=1:5
    for b=1:3 
        for i=1:size(images,2) %i è gli indici di test. La feature testata è l'i-esima
       
            t= setdiff(v,i); % vettore indici training, tutte le features tranne quella di test i-ma
        
            for k=1:size(t,2)%163
               training_features(k,:) = database.condizione(a).feature(b).matrice(t(k)).matrice;
               training_labels(k) =images(t(k)).etichetta;
            end
       
           test_feature = database.condizione(a).feature(b).matrice(i).matrice; %per il classifier     
           risultati.condizioni(a).cellsize(b).test(i).verita = images(i).etichetta; %ground truth per confronto
       
           %classifier
           classifier= fitcecoc(training_features, training_labels, 'Coding', 'onevsall');      
           risultati.condizioni(a).cellsize(b).test(i).predizioni= predict(classifier, test_feature);
       
         end
    end
end


%% Calcolo della matrice di confusione
for a=1:5
    for b=1:3
        analisi_dati.condizioni(a).cellsize(b).matrix_confusione = confusionmat(risultati.condizioni(a).cellsize(b).test.verita,...
            risultati.condizioni(a).cellsize(b).test.predizioni);
        
        analisi_dati.condizioni(a).cellsize(b).accuracy = trace(analisi_dati.condizioni(a).cellsize(b).matrix_confusione)/size(images,2);
        d = diag(analisi_dati.condizioni(a).cellsize(b).matrix_confusione);
        for i=1:size(analisi_dati.condizioni(a).cellsize(b).matrix_confusione,1)
            %calcolo recall
            analisi_dati.condizioni(a).cellsize(b).recall(i).recall = d(i)/...
              sum(analisi_dati.condizioni(a).cellsize(b).matrix_confusione(i,:));
            %calcolo precision
            analisi_dati.condizioni(a).cellsize(b).precision(i).precision = d(i)/...
              sum(analisi_dati.condizioni(a).cellsize(b).matrix_confusione(:,i));
        end   
    end
end

















