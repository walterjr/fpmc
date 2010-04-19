C   ============================================================================   C
C   FUNCTION INTEGM1:                                                              C
C   analytic part of the integrand                                                 C
C              Content: integrand, different defintions for the impact factor and  C
C              for the Sudakov form factor, definition of the coupling constants   C
C   ============================================================================   C
C   ==============================   Diagram 1   ===============================   C
C                --------                                   --------               C
C                 |   |                                       |   |                C
C                 |   |--                                   --|   |                C
C                 |   |--                                   --|   |                C
C                 |   |                                       |   |                C
C                --------                                   --------               C
C   ============================================================================   C
      function CHIDeQQM1(sigmaM1,a1,a2,b1,b2,k1,k2,k3,k,kp)         
	implicit none
      integer nf,iglu
      integer event,exp,Sudaf,grid,formfac,splash,nscale
      integer scale,Model,evolv,Vgrid,Lcut,interpol,moode,lhe
      double precision CHIDedot,CHIDedotsum,CHIDedothalf,IntegM1,as
      double precision fc,fs
      double precision phi,CHIDedphi,CHIDeephi 
      double precision b1,b2,k2(2),a1,a2
      double precision k(2),kp(2),k1(2),k3(2)
      double precision mk(2),mkp(2),mk1(2),mk2(2),mk3(2)
      double precision skk1(2),skpk1(2),skk3(2),skpk3(2)
      double precision mskk1(2),mskpk1(2),mskk3(2),mskpk3(2)
      double precision skk2(2),skpk2(2),mskk2(2),mskpk2(2)
      double precision skk2k3(2),mskk2k3(2),skpk2k3(2),mskpk2k3(2)
      double precision I2,I3,I3p,I4,I5
      double precision Ij,C0,C2,Ij0,Ij2
      double precision sgg,tgg,ugg
      double precision I1,J1,J2
      double precision pi,s,ncolor,gg,gq,kmax,nb,mp,cf
      double precision Ejet1,Ejet2
      double precision Sphi,Sphib,Sudaphi
      double precision phip,phipb,Ifact
      double precision CHIDedgd2008,CHIDedgd07,CHIDedgdforward
      double precision bo,ao
      double precision c,ael
      double precision x,xp
      double precision Dsuda
      double precision Rg,CHIDeprefac
      double precision amax,xmax,amin
      double precision Etcut,hygap,lygap,hbcutd,lbcutd,ycut
      double precision ylcut,hacutd,lacutd,Etmin,yclucut,propcut,yyj
      double precision CHIDedgdpol,Dsudapol

      double precision mq,bet

      common/const/pi,ncolor,gg,gq,kmax,nb,mp
      common/Energy/Ejet1,Ejet2
      common/integrand/tgg,sgg,ugg,Sudaphi,phi 
      common/flavor/nf
      common/switch/event,exp,Sudaf,grid,formfac,scale,Model,evolv,
     &              Vgrid,Lcut,interpol,moode,lhe,splash,nscale
      common/Ifactor/c,ael,iglu
      common/uncert/x,xp
      common/BotE/amax,xmax,amin
      common/cut/Etcut,hygap,lygap,hbcutd,lbcutd,ycut,
     &           ylcut,hacutd,lacutd,Etmin,yclucut,propcut,yyj
      common/kinematic/skk1,skpk1,skk3,skpk3,mskk1,mskpk1,mskk3,mskpk3,
     &                 mk3,skk2,skpk2,mskk2,mskpk2,mk2,skk2k3,
     &                 mskk2k3,skpk2k3,mskpk2k3,mk,mkp,mk1
      common/mquark/mq
      common/param/s

C   Common factor
      Ifact=pi**2/gq**2

C   ----------------------  M1: Num and Den  ---------------------------------   C
C     Numerator
      I2=CHIDedotsum(k,k1,kp,k1)*CHIDedotsum(k,k3,kp,k3)
      J2=CHIDedotsum(k,k1,k,k3)*CHIDedotsum(kp,k1,kp,k3)
     &-CHIDedotsum(k,k1,kp,k3)*CHIDedotsum(k,k3,kp,k1)

      bet=sqrt(1.-(4.*mq**2/sgg))
           
C     Numerator
      I1=(mq**2/4.)*(2.+bet)**2/sgg**3
     &    *(1.+(tgg-mq**2)/(ugg-mq**2)+(ugg-mq**2)/(tgg-mq**2))**2
      J1=4.*(bet*sgg-2.*tgg+2.*ugg)/bet/sgg
     &    *((tgg-ugg-bet*sgg)/(tgg-mq**2)/(ugg-mq**2))**2

      I2=CHIDedotsum(k,k1,kp,k1)*CHIDedotsum(k,k3,kp,k3)
      J2=CHIDedotsum(k,k1,k,k3)*CHIDedotsum(kp,k1,kp,k3)
     &-CHIDedotsum(k,k1,kp,k3)*CHIDedotsum(k,k3,kp,k1)

      Ij=(I1+J1)*I2+(I1-J1)*J2

C     Denominator!
      I3=CHIDedot(k,k)*CHIDedotsum(k,k1,k,k1)*CHIDedotsum(k,k3,k,k3)
      I3p=CHIDedot(kp,kp)*CHIDedotsum(kp,k1,kp,k1)
     &      *CHIDedotsum(kp,k3,kp,k3)

      if(CHIDedot(k,k).LT.propcut.or.CHIDedot(kp,kp).LT.propcut)goto 666
      if(CHIDedotsum(k,k1,k,k1).LT.propcut)goto 666
      if(CHIDedotsum(k,k3,k,k3).LT.propcut)goto 666
      if(CHIDedotsum(kp,k1,kp,k1).LT.propcut)goto 666
      if(CHIDedotsum(kp,k3,kp,k3).LT.propcut)goto 666  


C   ----------------------  M1: Impact Factor  --------------------------------   C
      if(formfac.EQ.1)then

        if(event.EQ.1)then
         phip=CHIDeephi(k,mskk1)*CHIDeephi(skpk1,mkp)
         phipb=CHIDeephi(mk,skk3)*CHIDeephi(mskpk3,kp)
        elseif(event.EQ.2)then
         phip=CHIDedphi(k,mskk1,skpk1,mkp)
         phipb=CHIDedphi(mk,skk3,mskpk3,kp) 
        elseif(event.EQ.3)then
         phip=CHIDedphi(k,mskk1,skpk1,mkp)
         phipb=CHIDeephi(mk,skk3)*CHIDeephi(mskpk3,kp)
        endif
         
      elseif(formfac.EQ.2)then

        if(event.EQ.1)then
         phip=CHIDedgd07(0.41d0*(b1+b2),CHIDedothalf(k,k1,k,k1),
     &    CHIDedot(k1,k1),CHIDedot(k,k1)+CHIDedot(k1,k1)/2.,iglu)
     &    *CHIDedgd07(0.41d0*(b1+b2),CHIDedothalf(kp,k1,kp,k1)
     &    ,CHIDedot(k1,k1),CHIDedot(kp,k1)+CHIDedot(k1,k1)/2.,iglu)
         phipb=CHIDedgd07(0.41d0*(a1+a2),CHIDedothalf(k,k3,k,k3),
     &    CHIDedot(k3,k3),CHIDedot(k,k3)+CHIDedot(k3,k3)/2.,iglu)
     &    *CHIDedgd07(0.41d0*(a1+a2),CHIDedothalf(kp,k3,kp,k3),
     &    CHIDedot(k3,k3),CHIDedot(kp,k3)+CHIDedot(k3,k3)/2.,iglu)
        elseif(event.EQ.2)then        
         phip=CHIDedgd2008(0.41d0*(b1+b2),CHIDedot(k,k),
     &        CHIDedotsum(k,k1,k,k1),CHIDedot(k1,k1))
     &        *CHIDedgd2008(0.41d0*(b1+b2),CHIDedot(kp,kp),
     &        CHIDedotsum(kp,k1,kp,k1),CHIDedot(k1,k1))
         phipb=CHIDedgd2008(0.41d0*(a1+a2),CHIDedot(k,k),
     &        CHIDedotsum(k,k3,k,k3),CHIDedot(k3,k3))
     &        *CHIDedgd2008(0.41d0*(a1+a2),CHIDedot(kp,kp),
     &        CHIDedotsum(kp,k3,kp,k3),CHIDedot(k3,k3))

        elseif(event.EQ.3)then
C     Exact definition of CHIDedgdforward -> Very slow
C      phip=CHIDedgdforward(0.41d0*(b1+b2),CHIDedothalf(k,k1,k,k1),iglu)
C     &*CHIDeprefac(k,mskk1,CHIDedot(k1,k1),b1+b2)
C     &*CHIDedgdforward(0.41d0*(b1+b2),CHIDedothalf(kp,k1,kp,k1),iglu)
C     &*CHIDeprefac(skpk1,mkp,CHIDedot(k1,k1),b1+b2)
C      phipb=CHIDedgdforward(0.41d0*(a1+a2),CHIDedothalf(k,k3,k,k3),iglu)
C     &*CHIDeprefac(mk,skk3,CHIDedot(k3,k3),a1+a2) 
C     &*CHIDedgdforward(0.41d0*(a1+a2),CHIDedothalf(kp,k3,kp,k3),iglu)
C     &*CHIDeprefac(mskpk3,kp,CHIDedot(k3,k3),a1+a2)

C    Interpolation of CHIDedgdforward
       phip=CHIDedgdpol(b1+b2,CHIDedothalf(k,k1,k,k1))
     &      *CHIDeprefac(k,mskk1,CHIDedot(k1,k1),b1+b2)
     &      *CHIDedgdpol(b1+b2,CHIDedothalf(kp,k1,kp,k1))
     &      *CHIDeprefac(skpk1,mkp,CHIDedot(k1,k1),b1+b2)
      phipb=CHIDedgdpol(a1+a2,CHIDedothalf(k,k3,k,k3))
     &      *CHIDeprefac(mk,skk3,CHIDedot(k3,k3),a1+a2) 
     &      *CHIDedgdpol(a1+a2,CHIDedothalf(kp,k3,kp,k3))
     &      *CHIDeprefac(mskpk3,kp,CHIDedot(k3,k3),a1+a2)
        endif
       endif

C   -------------------  M1:Sudakov Form Factor  -------------------------------   C 
C     Durham Sudakov factor
      if(sudaf.EQ.1)then
       if(interpol.EQ.2)then
         if(scale.EQ.1)then
       Sphi=Dsuda(CHIDedot(k2,k2)/x,CHIDedot(k,k)/xp)
       Sphib=Dsuda(CHIDedot(k2,k2)/x,CHIDedot(kp,kp)/xp)
         elseif(scale.EQ.2)then
           Sphi=sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skk1,skk1)/xp))
     &      *sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skk3,skk3)/xp))
           Sphib=sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skpk1,skpk1)/xp))
     &      *sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skpk3,skpk3)/xp))
         endif

       elseif(interpol.EQ.1)then
         if(scale.EQ.1)then
       Sphi=Dsudapol(CHIDedot(k2,k2)/x,CHIDedot(k,k)/xp)
       Sphib=Dsudapol(CHIDedot(k2,k2)/x,CHIDedot(kp,kp)/xp)
         elseif(scale.EQ.2)then
        Sphi=sqrt(Dsudapol(CHIDedot(k2,k2)/x,CHIDedot(skk1,skk1)/xp))
     &       *sqrt(Dsudapol(CHIDedot(k2,k2)/x,CHIDedot(skk3,skk3)/xp))
        Sphib=sqrt(Dsudapol(CHIDedot(k2,k2)/x,CHIDedot(skpk1,skpk1)/xp))
     &       *sqrt(Dsudapol(CHIDedot(k2,k2)/x,CHIDedot(skpk3,skpk3)/xp))

          endif
       endif  

C     DDT Sudakov form factor
      elseif(sudaf.EQ.2)then

         if(scale.EQ.1)then
       Sphi=Dsuda(CHIDedot(k2,k2)/x,CHIDedot(k,k)/xp)
       Sphib=Dsuda(CHIDedot(k2,k2)/x,CHIDedot(kp,kp)/xp)
         elseif(scale.EQ.2)then
           Sphi=sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skk1,skk1)/xp))
     &      *sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skk3,skk3)/xp))
           Sphib=sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skpk1,skpk1)/xp))
     &      *sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skpk3,skpk3)/xp))
         endif

C     DLA Sudakov form factor
      elseif(sudaf.EQ.3)then

         if(scale.EQ.1)then
       Sphi=Dsuda(CHIDedot(k2,k2)/x,CHIDedot(k,k)/xp)
       Sphib=Dsuda(CHIDedot(k2,k2)/x,CHIDedot(kp,kp)/xp)
         elseif(scale.EQ.2)then
           Sphi=sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skk1,skk1)/xp))
     &      *sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skk3,skk3)/xp))
           Sphib=sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skpk1,skpk1)/xp))
     &      *sqrt(Dsuda(CHIDedot(k2,k2)/x,CHIDedot(skpk3,skpk3)/xp))
         endif
                 

C   Exhume like: Dhuram group with sgg scale
      elseif(sudaf.EQ.4)then 
         
        if(scale.EQ.1)then
         Sphi=Dsuda(sgg/x,CHIDedot(k,k)/xp)
         Sphib=Dsuda(sgg/x,CHIDedot(kp,kp)/xp)
        elseif(scale.EQ.2)then 
         Sphi=sqrt(Dsudapol(sgg/x,CHIDedot(skk1,skk1)/xp))
     &      *sqrt(Dsudapol(sgg/x,CHIDedot(skk3,skk3)/xp))
         Sphib=sqrt(Dsudapol(sgg/x,CHIDedot(skpk1,skpk1)/xp))
     &      *sqrt(Dsudapol(sgg/x,CHIDedot(skpk3,skpk3)/xp)) 
        endif 
  
C   Naive Sudakov Factor      
      elseif(sudaf.EQ.5)then

       Sphi=Dexp(-3./pi/2.*as(CHIDedot(k2,k2)/x)
     &*((log(CHIDedot(skk3,skk3)/CHIDedot(k2,k2)/xp)
     &*log(CHIDedot(skk1,skk1)/CHIDedot(k2,k2)/xp))))
       Sphib=Dexp(-3./pi/2.*as(CHIDedot(k2,k2)/x)
     &*((log(CHIDedot(skpk3,skpk3)/CHIDedot(k2,k2)/xp)
     &*log(CHIDedot(skpk1,skpk1)/CHIDedot(k2,k2)/xp))))

C     No Sudakov Factor
      elseif(sudaf.EQ.7)then
       Sphi=1.d0
       Sphib=1.d0 
      endif

C   -------------------------------  Diag1=M1  -----------------------------------  C 
C     Sudakov en Impact
      if(formfac.EQ.1)then
       phi=phip*phipb
      elseif(formfac.EQ.2)then
       phi=Ifact**4*phip*phipb
      endif  
      Sudaphi=Sphi*Sphib

C     Coefficient, function and phase space
C     First pick up the corresponding value of gg(as) from 
C     subroutine and ael,aDD from sigmael.f
      factsp=1./16./(2.*pi)**8/b1/b2
      factp=81.              !3 quarks in p+ 
      gq=sqrt(4.*pi*CHIDeas(sgg))
      fact=gq**4*gq**8*nb/4./pi**4

C     Regge factor
      if(formfac.EQ.1)then
      a1t=0.09d0-0.3d0*CHIDeCHIDedot(k1,k1)/(1.-(b1+b2))
      a3t=0.09d0-0.3d0*CHIDeCHIDedot(k3,k3)/(1.-(a2+a1))
      regge=((1./(a2+a1))**a1t*(1./(b1+b2))**a3t)**2
      else
       regge=1.d0
      endif

C    Color factor
C      Cf=1./64./ncolor**4
      Cf=1.


C    Function M1
      sigmaM1=Cf*Ij*Sudaphi*phi/I3/I3p

C    Debug tools  
C      print*,'In Diag 1:'
C      print*,'phi=',phi,phip,phipb
C      print*,'in phip=',CHIDeprefac(k,mskk1,CHIDedot(k1,k1),b1+b2)
C     &,k,mskk1,CHIDedot(k1,k1),b1+b2
C      print*,'Fact,Ifact=',Ifact,pi,gq
C      print*,'Suda=',Sudaphi,Sphi,Sphib
C      print*,'Deno, Numo',I3*I3p,Ij
C      print*,'********************************'    

      goto 66
666   sigmaM1=0.
66    end


