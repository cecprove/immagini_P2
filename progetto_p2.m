%% P2
% crea database
imagespath=dir('C:\Users\cecil\Documents\Universita\ElaborazioneImmagini\Progetto\Database_per_gli_elaborati_di_Tipo_2_20190202\Yale\Yale');
imagespath;
ImagesPath=imagespath(4:end,:);% Per eliminare i primi tre elementi che non sono immagini
images=struct;
lista_tipologie=struct;
for i=1:size(ImagesPath,1)
    images(i).images=imread([ImagesPath(i).folder,'/',ImagesPath(i).name]);
    % creo il path totale dell'immagine, quindi
    % sto caricando con ogni ciclo la struttura ad ogni immagine
    % Se volessi solo l'immagine 7 scriverò images(7).images e gli dico di
    % andare a prendere la settima immagine che ha  caricato nel database, in
    % questo caso la struct
    %creo struct con tuttii nomi delle immagini
    lista_tipologie(i).lista = extractAfter(ImagesPath(i).name,".");
end

lista_stringhe = string(lista_tipologie(1).lista);

for i=1:size(lista_tipologie,2)
    %prendo tutti i nomi dalla struct e li confronto con quelli presente in
    %lista_stringhe
    count = 0;
    for k=1:size(lista_stringhe,1)
        if count ==0 && ~strcmp(lista_tipologie(i).lista, lista_stringhe(k))
        else
            count = 1;
        end
    end
    if count == 0
        %aggiungo la nuova tipologia in lista_stringhe
        lista_stringhe = [lista_stringhe;string(lista_tipologie(i).lista)];
    end
end

% creo la struttura database.dimensione.dominio(a).immagini(b).matrice.matrice 
% a= 1--> immagine e a=2 --> HOGfeature
% b= 1 --> non riferimento e b= 2 --> riferimento
a=1;
b=1;
while a==1 && b==1
    for i=1:size(ImagesPath,1)
        database.dimensione.dominio(a).immagini(b).matrice(i).matrice=images(i).images;
    end
    a=a+1;
    b= b+1;
end

% creo etichette
stringa_sub = '01';
a=1;
b=2;
while a==1 && b==2
for i=1:size(lista_stringhe,1)
    for k=1:size(ImagesPath,1)
        if strcmp(extractAfter(ImagesPath(k).name,"."),lista_stringhe(i))&& ...
                strcmp(extractBefore(ImagesPath(k).name,"."),['subject',stringa_sub])
            database.dimensione.dominio(a).immagini(b).matrice(i).matrice = imread([ImagesPath(k).folder,'/',ImagesPath(k).name]);
            database.dimensione.dominio(a).immagini(b).matrice(i).tipologia = extractAfter(ImagesPath(k).name,".");
            database.dimensione.dominio(a).immagini(b).matrice(i).soggetto = extractBefore(ImagesPath(k).name,".");
            switch stringa_sub
                case '01'
                    stringa_sub = '02';
                case '02'
                    stringa_sub = '03';
                case '03'
                    stringa_sub = '04';
                case '04'
                    stringa_sub = '05';
                case '05'
                    stringa_sub = '06';
                case '06'
                    stringa_sub = '07';
                case '07'
                    stringa_sub = '08';
                case '08'
                    stringa_sub = '09';
                case '09'
                    stringa_sub = '10';
                case '10'
                    stringa_sub = '11';
            end
            break;
        end
    end
end
a=a+1;
b=b+1;
end 

% cerco gli indici in cui trovo le immagini di riferimento quindi effettuo
% la ricerca nelle immagini di riferimento confrontando con il path
a=1;
b=2;
while a==1 && b==2
    for i=1:size(lista_stringhe,1)
        for k=1:size(ImagesPath,1)
            if strcmp(extractAfter(ImagesPath(k).name,"."),database.dimensione.dominio(a).immagini(b).matrice(i).tipologia)&& ...
                strcmp(extractBefore(ImagesPath(k).name,"."),database.dimensione.dominio(a).immagini(b).matrice(i).soggetto)
                indici(i) = k;
            end
        end
        
    end
    a=a+1;
    b=b+1;
end

% togliamo in immagini non riferimento le immagini di riferimento
a=1;
b=1;
while a==1 && b==1
    for k=1: size(indici,2)       
        for i=1:size(database.dimensione.dominio(a).immagini(b).matrice,2)
            if(i == indici(k))
                database.dimensione.dominio(a).immagini(b).matrice(i).matrice = [];
            end
        end        
    end
    a=a+1;
    b=b+1;
end

% proviamo proprio ad eliminare le matrici vuote
a=1;
b=1;
while a==1 && b==1
    for i=1:size(database.dimensione.dominio(a).immagini(b).matrice,2)
       if isempty(database.dimensione.dominio(a).immagini(b).matrice(i).matrice) 
           for k=i:(size(images,2)-1)                  
               database.dimensione.dominio(a).immagini(b).matrice(k).matrice = database.dimensione.dominio(a).immagini(b).matrice(k+1).matrice;
           end
       end
    end
    % per eliminare la vuota al posto 100
    for i=1:size(database.dimensione.dominio(a).immagini(b).matrice,2)
       if isempty(database.dimensione.dominio(a).immagini(b).matrice(i).matrice) 
           for k=i:(size(images,2)-1)                  
               database.dimensione.dominio(a).immagini(b).matrice(k).matrice = database.dimensione.dominio(a).immagini(b).matrice(k+1).matrice;
           end
       end
    end
   a=a+1;
   b=b+1;
end

% tagliamo il vettore per togliere le ultime 11
a=1;
b=1;
database.dimensione.dominio(a).immagini(b).matrice = database.dimensione.dominio(a).immagini(b).matrice(1:153);

%% creiamo le HOG feature
% creaimo le hog sia per le immagini di riferimento e per tutte le immagini
a=2;
b=1;
v=[0 2 4 8];
while a<5
   b=1;
   while b<3
       if b==1 %sono nelle immagni totali
          for i=1:size(database.dimensione.dominio(1).immagini(1).matrice,2)
           [database.dimensione.dominio(a).immagini(b).matrice(i).matrice,visualization] = extractHOGFeatures(database.dimensione.dominio(1).immagini(1).matrice(i).matrice, ...
               'CellSize',[v(a) v(a)]);
           end          
       end
       
       if b==2 % sono nelle immagini di riferimento
           for i=1:size(database.dimensione.dominio(1).immagini(2).matrice,2)
           [database.dimensione.dominio(a).immagini(b).matrice(i).matrice,visualization] = extractHOGFeatures(database.dimensione.dominio(1).immagini(2).matrice(i).matrice, ...
               'CellSize',[v(a) v(a)]);
           end 
       end
        b=b+1;
   end
   a=a+1;
end

%prova
%imshow(database.dimensione.dominio(1).immagini(2).matrice(11).matrice);
%hold on
%plot(visualization)






