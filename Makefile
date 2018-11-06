
#Cartella dei file obj
OBJDIR := build

#compilatore
CC = g++

#flag compilatore
CPPFLAGS = -MMD -ggdb

#NOME DEL PROGETTO
# dal comando di shell pwd estrae il percorso corrente del makefile
progetto1 := $(shell pwd)
#sostituisce i simboli / con lo spazio
progetto2 := $(subst /, , $(progetto1))
#e infine estrae l'ultima parola che è il nome della cartella corrente che
#sara' anche il nome del file eseguibile
PROGETTO := $(lastword $(progetto2))

#legge le sottocartelle del progetto attuale e le copia nella viariabile
#non ricorsiva cartelle. Di tutte le cartelle presenti filtra (elimina)
#quella di nome Debug
cartelle := $(filter-out  $(OBJDIR)/, $(wildcard */))

#Percorso degli include dei file header locali. Deve aggiungere la stringa -I
# a ciascuna cartella presente nella variabile 'cartelle'
INCLDIR = $(addprefix -I, $(cartelle))


#mette nella viariabile file.C tutti i file .c presenti nelle
#cartelle che ha scoperto e li rappresenta con percorso completo
file.C := $(foreach i, $(cartelle), $(wildcard $(i)*.c))
file.CPP := $(foreach i, $(cartelle), $(wildcard $(i)*.cpp))

#elimina l'indicazione delle cartelle dal nome dei file in modo
#da creare i file object in un'unica cartella
soloFile := $(notdir $(file.C))
soloFileCPP := $(notdir $(file.CPP))

#produce un elenco di file object derivati per sostituzione di .c in .o
file.o := $(file.C:.c=.o)
file.o += $(file.CPP:.cpp=.o)

#produce un elenco i file object derivati per sostituzione di .c in .o e senza
#indicazione della cartella di appartenenza
soloFile.o := $(soloFile:.c=.o)
soloFile.o += $(soloFileCPP:.cpp=.o)
File.d := $(file.C:.c=.d)

#imposta il percorso di ricerca dei file .c nelle cartelle di progetto
VPATH = $(cartelle)

#si cotruisce l'elenco dei file .o precedeuto dalla stringa Debug/
OBJS := $(addprefix $(OBJDIR)/, $(soloFile.o))

#cartella dipendenze
depdir = $(OBJS:%.o=%.d)
# la variabile $(OBJS:%.o=%.d) riporta la sostituzione nella variabile $(OBJDIR)
# di tutte le istanze .o con le istanze .d, e quindi mantenendo il percorso se
# e' presente.

#target dell'eseguibile: ha il nome della cartella principale ed ha come
#prerequisiti tutti i file .o presenti in $(OBJS)/
$(PROGETTO): $(OBJS)
	$(CC) -o $@ $^
	size $@

-include $(depdir)

#target di ciascun file .o. Usa una regola pattern dove ciascun file target
#ha come prerequisito lo stesso file ma con estensione .c. La wildcard % agisce
#tuttavia solo sul nome del file in modo da non obbligare i prerequisiti a
#risiedere nella cartella Debug/. Quindi il target e' ad esempio Debug/main.o ma
#esso e' prodotto da main.c e non da Debug/main.c. Poiche' main.c non e' nella
#cartella principale del progetto, e' stata impostata la variabile VPATH con la
#quale make cerca le corrispondenze %.o con %.c


$(OBJDIR)/%.o : %.c
	mkdir -p $(@D)
	@echo 'compilo $@'
	gcc -MMD -Wall $(INCLDIR) -c $< -o $@

$(OBJDIR)/%.o : %.cpp
	mkdir -p $(@D)
	@echo 'compilo $@'
	g++  $(CPPFLAGS)  $(INCLDIR) -c $< -o $@



.PHONY: list clean

#scopi di debug del makefile
list:
	@echo $(cartelle)
	@echo 'cartelle incluse'
	@echo $(INCLDIR)
	@echo $(file.C)
	@echo $(file.CPP)
	@echo $(soloFile)
	@echo $(file.o)
	#rm $(file.o)
	@echo 'solo file .o'
	@echo $(soloFile.o)
	@echo 'OBJS'
	@echo $(OBJS)
	@echo $(VPATH)
	@echo $(progetto2)
	@echo $(PROGETTO)
	@echo $(depdir)


clean:
	rm $(PROGETTO)
	rm $(OBJDIR)/ -R
