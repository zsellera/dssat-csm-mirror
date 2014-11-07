!***************************************************************************************************************************
! This is the code from the section (DYNAMIC.EQ.INTEGR) lines 8387 - 8515 of the original CSCAS code. The names of the 
! dummy arguments are the same as in the original CSCAS code and the call statement and are declared here. The variables 
! that are not arguments are declared in Module_CSCAS_Vars_List. Unless identified as by MF, all comments are those of 
! the original CSCAS.FOR code.
!
! Subroutine CS_Out_LfTeir outputs details of leaves and tiers. 
!***************************************************************************************************************************
    
    SUBROUTINE CS_Out_LfTier ( & 
        IDETL       , RUN         , STGYEARDOY   &
        )
        
        USE ModuleDefs                                         ! MF 31AU14 ADDED FOR ACCESS TO WEATHER
        USE ModuleData
        USE Module_CSCAS_Vars_List
        USE Module_CS_Formats
     
        IMPLICIT NONE 
     
        INTEGER :: RUN         , STGYEARDOY(20)            

        CHARACTER(LEN=1)  :: IDETL       
    
        !-----------------------------------------------------------------------------------------------------------
        !         Output leaves and tiers data (IDETL = Y or D)
        !-----------------------------------------------------------------------------------------------------------
        IF (IDETL.EQ.'Y'.OR.IDETL.EQ.'D'.OR.IDETL.EQ.'A') THEN
                    
            ! LEAVES.OUT
            OPEN(UNIT=FNUMLVS,FILE=FNAMELEAVES,POSITION='APPEND')
            WRITE (FNUMLVS,'(/,A79,/)') OUTHED
            WRITE (FNUMLVS,'(A14,F6.1)') '! LEAF NUMBER ',LNUM
            WRITE (FNUMLVS,'(/,A48,A36,A30)')'@ LNUM AREAP AREA1 AREA2 AREA3 AREA4 AREAT AREAS', &
                '  WFLF  NFLF NFLF2  AFLF TFGLF TFDLF',' LLIFG LLIFA LLIFS LLIFE   DAP'
            DO I = 1, INT(LNUM+0.99)
                CALL Csopline(lapotxc,lapotx(i))
                CALL Csopline(latlc,AMAX1(0.0,LATL(i)))
                CALL Csopline(latl2c,AMAX1(0.0,LATL2(i)))
                CALL Csopline(latl3c,AMAX1(0.0,LATL3(i)))
                CALL Csopline(latl4c,AMAX1(0.0,LATL4(i)))
                CALL Csopline(lapc,lap(i))
                CALL Csopline(lapsc,laps(i))
                ! Adjust for growth period of non fullly expanded leaves
                WFLF(I) = AMIN1(1.0,WFLF(I)/AMIN1(1.0,(LAGETT(I)/LLIFG)))
                NFLF(I) = AMIN1(1.0,NFLF(I)/AMIN1(1.0,(LAGETT(I)/LLIFG)))
                NFLFP(I) =AMIN1(1.0,NFLFP(I)/AMIN1(1.0,(LAGETT(I)/LLIFG)))
                TFGLF(I) =AMIN1(1.0,TFGLF(I)/AMIN1(1.0,(LAGETT(I)/LLIFG)))
                AFLF(I) = AMIN1(1.0,AFLF(I)/AMIN1(1.0,(LAGETT(I)/LLIFG)))
                IF (LDEATHDAP(I).EQ.0) LDEATHDAP = -99
                WRITE (fnumlvs,'(I6,7A6,6F6.2,4F6.1,I6)')I,LAPOTXC,LATLC,LATL2C,LATL3C,LATL4C,LAPC,LAPSC,1.0-WFLF(I), &
                    1.0-NFLF(I),1.0-NFLF2(I),1.0-AMAX1(0.0,AMIN1(1.0,AFLF(I))),1.0-TFGLF(I),1.0-TFDLF(I),DGLF(I), &
                    DALF(I),DSLF(I),DGLF(I)+DALF(I)+DSLF(I),LDEATHDAP(I)
            ENDDO
            IF (RUN.EQ.1) THEN
                WRITE(fnumlvs,*)' '
                WRITE(fnumlvs,'( A)')'! NB. Data are summed over all fork branches'
                WRITE(fnumlvs,*)' '
                WRITE(fnumlvs,'( A)')'! LNUM = Number of leaf on one axis '
                WRITE(fnumlvs,'( A)')'! AREAP = Potential area of leaf on main axis (cm2) '
                WRITE(fnumlvs,'(2A)')'! AREA1 = Area of youngest mature leaf on', ' main axis,no stress (cm2)'
                WRITE(fnumlvs,'(2A)')'! AREAT = Area of cohort of leaves at leaf',' position (cm2) '
                WRITE(fnumlvs,'(2A)')'! AREAS = Senesced area of cohort of leaves', ' at harvest at leaf position (cm2) '
                WRITE(fnumlvs,'(2A)')'! WFLF  = Water stress factor for leaf',' (0-1,1=0 stress)'
                WRITE(fnumlvs,'( A)')'! NFLF  = N stress factor for leaf (0-1,1=0 stress)'
                WRITE(fnumlvs,'( A)')'! NFLF  = N factor for area adjustment (0-1,1=0 stress)'
                WRITE(fnumlvs,'(2A)')'! NFLFP = N stress factor for photosynthesis',' (0-1,1=0 stress)'
                WRITE(fnumlvs,'(2A)')'! AFLF  = Assimilate factor for leaf',' (0-1,1=0 no limitation)'
                WRITE(fnumlvs,'(2A)')'! TFGLF = Temperature factor for leaf expansion ',' (0-1,1=0 no limitation)'
                WRITE(fnumlvs,'(2A)')'! TFDLF = Temperature factor for leaf development',' (0-1,1=0 no limitation)'
                WRITE(fnumlvs,'( A)')'! DGLF = Number of days growing      '
                WRITE(fnumlvs,'( A)')'! DALF = Number of days fully active '
                WRITE(fnumlvs,'( A)')'! DSLF = Number of days senescing    '
            ENDIF
            CLOSE (FNUMLVS)
            ! End of Leaves.out
                    
            ! Branching tier conditions (Simulated; TIERS.OUT)
            OPEN(UNIT=FNUMPHA,FILE=FNAMEPHASES,POSITION='APPEND')
            WRITE (FNUMPHA,'(/,A79,/)') OUTHED
            WRITE (fnumpha,'(A42,A24,A12)')'@ TIER SRADA  TMXA  TMNA  PREA  TWLA  CO2A','  WFPA  WFGA  NFPA  NFGA', &
                '  TIER_END  '
            DO L=1,MSTG-2
                IF (STGYEARDOY(L).LT.9999999.AND.L.NE.0.AND.L.NE.10.AND.L.NE.11) &
                    WRITE (fnumpha,'(I6,3F6.1,2F6.2,I6,4F6.2,1X,A13)')L,sradpav(L),tmaxpav(L),tminpav(L),rainpav(L), &
                    daylpav(L),NINT(co2pav(L)),1.0-wfppav(L),1.0-wfgpav(L),1.0-nfppav(L),1.0-nfgpav(L), &
                    psname(MIN(L+1,PSX))
            ENDDO
            IF(yeardoyharf.EQ.yeardoy)THEN
                WRITE (fnumpha,'(I6,3F6.1,2F6.2,I6,4F6.2,1X,A13)')mstg-1,sradpav(mstg-1),tmaxpav(mstg-1), &
                    tminpav(mstg-1),rainpav(mstg-1),daylpav(mstg-1),NINT(co2pav(mstg-1)),1.0-wfppav(mstg-1), &
                    1.0-wfgpav(mstg-1),1.0-nfppav(mstg-1),1.0-nfgpav(mstg-1),'Harvest      '
            ELSE 
                WRITE (fnumpha,'(I6,3F6.1,2F6.2,I6,4F6.2,1X,A13)')mstg-1,sradpav(mstg-1),tmaxpav(mstg-1), &
                    tminpav(mstg-1),rainpav(mstg-1),daylpav(mstg-1),NINT(co2pav(mstg-1)),1.0-wfppav(mstg-1), &
                    1.0-wfgpav(mstg-1),1.0-nfppav(mstg-1),1.0-nfgpav(mstg-1),psname(mstg)
            ENDIF
            CLOSE (FNUMPHA)
                    
        ELSE
                    
            OPEN (UNIT=FNUMLVS,FILE=FNAMELEAVES,STATUS='UNKNOWN')
            CLOSE (UNIT=FNUMLVS, STATUS = 'DELETE')
            OPEN (UNIT=FNUMPHA,FILE=FNAMEPHASES,STATUS = 'UNKNOWN')
            CLOSE (UNIT=FNUMPHA, STATUS = 'DELETE')
        ENDIF
        ! End of Leaves and Tier writes
    END SUBROUTINE CS_Out_LfTier
