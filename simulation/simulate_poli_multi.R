#rm(list=ls())  

           #####    POLI-MULTI  ######


########ARGUMENTOS:

#size.cluster: tamaño de cada cluster de items (dim. teorica)
#dim.data: dimension de los datos, (dim. practica)
#sample.size: num de individuos
#ncatgs: numero de categorias por cada item

########DEVUELVE:

#1.  test 
#2.  parámetros con los que se generó, bajo la parámetrizacion
#en la que se distribuye la discriminacion, en el predictor lineal
#3. indices de cada cluster de items


#normal truncada y funcion que normaliza vectores:

source("C:/Users/Milder/Desktop/poli_multidimensional/rtnorm.r")


simulate.poli.multi=function(size.cluster=c(25,25,25,25),
                            dim.data=3,sample.size=1000,
                            ncatgs=rep(3,sum(size.cluster)), seed_data = 1273  ){
  
  #tamaño del test(num. de items)
  K=sum(size.cluster)
  
  #dimension teorica, numero de clusters
  num.cluster=length(size.cluster)
  
  #indices para especificar items por cada cluster
  ind2=cumsum(size.cluster)
  ind1=c(1,ind2[-length(ind2)]+1)
  
  #vectores directores principales
  set.seed(2)
  dir.beta.1=matrix(runif(dim.data^2,min=0.08,max=0.28),
                    nrow = dim.data,ncol = dim.data)
  
  if(num.cluster!=dim.data){
    dir.beta.2=rbind(dir.beta.1,
                     matrix(rep(1,dim.data*(num.cluster-dim.data)),ncol=dim.data))
    diag(dir.beta.2)=1
    dir.beta=normalize(dir.beta.2)
  }else{
    diag(dir.beta.1)=1
    dir.beta=normalize(dir.beta.1)
  }
  
  
  ##ruido, variacion respecto a los vectores directores principales
  noise <- seq(0.08, 0.25 ,length.out=num.cluster)
  
  ##betas, vectores directores de cada item
  betas.1 = matrix(NA,K,dim.data)
  
  # semilla para generar los vectores directores de cada ítem.
  seed_beta <- 100L
  set.seed(seed_beta)
  
  #generando los vectores directores de cada item:
  for(i in 1:length(ind1)){
    betas.1[ind1[i]:ind2[i],]=
      matrix(dir.beta[i,], size.cluster[i],dim.data,byrow=TRUE)+matrix(runif(size.cluster[i]*dim.data,-noise[i],noise[i]), size.cluster[i],dim.data)
  }
  
  # replace  negative componentes
  
  betas.2=ifelse(betas.1<0,0,betas.1)
  betas=normalize(betas.2)
  
  
  ##se fijan d vectores directores al origen de la dimension de los datos
  #para resolver la falta de identificabilidad del modelo
  for(i in 1:dim.data){
    betas[ind1[i],i]=1 ; betas[ind1[i],-i]=0
  }
  
  
  ##se calculan los vectores directores principales "reales"
  dir_betas=matrix(NA,nrow=num.cluster,ncol=dim.data)
  
  for(i in 1:nrow(dir_betas)){
    dir_betas[i,]=abs(eigen(t(betas[ind1[i]:ind2[i],])%*%betas[ind1[i]:ind2[i],])$vectors)[,1]
  }
  
  
  #######################################################################
  # 2.item parameters
  #######################################################################
  
  # alpha params
  # seed for reproductibility
  seed_alpha <- 400L
  set.seed(seed_alpha)
  l_a=0.25
  u_a = Inf
  
  
  #se simulan las normas de los alphas
  norm.alphas<-rtnorm(K, mean = 0, sd = 1.0, lower = l_a,  upper = u_a)
  
  #se generan los alpha,(alpha=beta|alpha|)
  alphas = betas * matrix(norm.alphas, K, dim.data, byrow=FALSE)
  
  
  #se fijan d alphas para resolver la no identificabilidad.
  for(i in 1:dim.data){
    alphas[ind1[i],i]=1 ; alphas[ind1[i],-i]=0
  }
  
  
  ##########################!!!!!
  
  # umbrales*normas
  # seed for reproductibility
  seed_gamma <- 250L
  set.seed(seed_gamma)
  
  deltas=vector("list",length = K)
  umbrales=vector("list",length = K)
 
  ##generando deltas, las distancias entre umbrales 
  for(l in 1:K){
   deltas[[l]]=c(runif(1,-1.5,-1),rnorm((ncatgs[l]-2),0,0.4))
  }
  
  ##generando los umbrales
  umbrales=lapply(deltas,function(x)cumsum(c(x[1],exp(x[-1]))))
  
  ##distribuyendo la norma (hallando el d)
  Gamma=list()
  for(l in 1:K){
    Gamma[[l]]=-as.vector(umbrales[[l]])*norm.alphas[l]
  }
  
  
  ##no identificabilidad
  #for(i in 1:dim.data){
   # Gamma[[ind1[i]]][1]=0
  #  }
  
  
  Gamma[[ind1[1]]][2]=0
  Gamma[[ind1[2]]][2]=0
  
  
  #######################################################################
  # 3. latent traits
  #######################################################################
  # sample size
  
  seed.5 <-500L
  set.seed(seed.5)
  theta <- matrix(rnorm(sample.size*dim.data,0,1),sample.size,dim.data)
  # this line is to garantee the the covariance matrix is the identity
  theta <- theta %*% solve((chol(cov(theta))))
  theta.true <- theta
  
  
  #######################################################################
  # 3. test data
  #######################################################################
  
 ######################################
  #  3.1 probability
  #####################################

  ##pasteriscos:
  
  etas=list()
  thet.alpha=theta%*%t(alphas)
  for(j in 1:ncol(thet.alpha)){ 
  etas[[j]]=thet.alpha[,j]+
  matrix(Gamma[[j]],byrow=T,nrow=nrow(thet.alpha),ncol=length(Gamma[[j]]))
  }
  
  past.1=lapply(etas,function(x){1/(1+exp(-x))})
  past=lapply(past.1,function(x) cbind(1,x,0))
  probs=lapply(past,function(x) x[,-ncol(x)]-x[,-1])
  #lapply(probs,function(x)rowSums(x))
  
  #####################################
  #  3.2 Test data
  #####################################
  
  set.seed(seed_data)
  
  Y=matrix(NA,nrow=sample.size,ncol=K)
  for(i in 1:sample.size){
  for(j in 1:K){
    Y[i,j]=sample(1:ncatgs[j],1,prob = probs[[j]][i,])
     }
    }
  
  params.it=list()
  for(j in 1:length(umbrales))
  {params.it[[j]]=c(Gamma[[j]],alphas[j,])}
  
  
  retorno=list(data=Y,params.it=params.it,theta=theta,indclust1=ind1,indclust2=ind2)
  return(retorno)
}


#PRIMER ESCENARIO 1000 INDIVIDUOS X 50 ITEMS, 2 DIMENSIONES, 3 CATEGORIAS
#un escenario particular:
size.cluster=c(25,25)
sims = list()
for ( i in 1:100 ) {
  sim=simulate.poli.multi(size.cluster=size.cluster,dim.data=2, seed_data = i)  
  Y = sim$data
  sims[[i]] = sim
  #write.table(Y, file = paste(c("poly-multi-tests/escenario/poly-multi", i,".csv"), collapse = ""), sep = ";",col.names = FALSE, row.names = FALSE)
}

sims[[1]]$params.it


#simm=simulate.poli.multi(size.cluster = c(5,5),dim.data = 2,sample.size = 1000,ncatgs = rep(3,10), seed_data = 3)
#write.table(simm$data,"~/Desktop/simdatapolimulti.txt")
#simm$params.it
Y=simm$data
write.table(Y, file = "ejem.csv", sep = ";",col.names = FALSE, row.names = FALSE)
#write.table(do.call(rbind,simm$params.it),"~/Desktop/Parametrosdesim.txt")

#sim=simulate.poli.multi()
#names(sim)

####análisis paralelo:

#un escenario particular:
#size.cluster=c(25,25,25,25,25)
#sim=simulate.poli.multi(size.cluster=size.cluster,dim.data=5)
#Y=sim$data


#otro escenario
#ncatgs=c(rep(3,50),rep(5,50))
#sim=simulate.poli.multi(ncatgs = ncatgs)
#Y=sim$data

#library(FactoMineR)
#library(paran)
#acp=PCA(Y,graph=F)  #acp con el item alterado
#histdevalorespropios=barplot(acp$eig$eigen,main="Histograma de Valores Propios",plot=T)
#paran(Y, iterations=100, centile=95,graph=TRUE)
