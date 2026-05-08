    function targMap = targDataMap(),

    ;%***********************
    ;% Create Parameter Map *
    ;%***********************
    
        nTotData      = 0; %add to this count as we go
        nTotSects     = 1;
        sectIdxOffset = 0;

        ;%
        ;% Define dummy sections & preallocate arrays
        ;%
        dumSection.nData = -1;
        dumSection.data  = [];

        dumData.logicalSrcIdx = -1;
        dumData.dtTransOffset = -1;

        ;%
        ;% Init/prealloc paramMap
        ;%
        paramMap.nSections           = nTotSects;
        paramMap.sectIdxOffset       = sectIdxOffset;
            paramMap.sections(nTotSects) = dumSection; %prealloc
        paramMap.nTotData            = -1;

        ;%
        ;% Auto data (rtP)
        ;%
            section.nData     = 52;
            section.data(52)  = dumData; %prealloc

                    ;% rtP.Cth_gain
                    section.data(1).logicalSrcIdx = 0;
                    section.data(1).dtTransOffset = 0;

                    ;% rtP.Ea_cal
                    section.data(2).logicalSrcIdx = 1;
                    section.data(2).dtTransOffset = 1;

                    ;% rtP.F_const
                    section.data(3).logicalSrcIdx = 2;
                    section.data(3).dtTransOffset = 2;

                    ;% rtP.P_ch_max
                    section.data(4).logicalSrcIdx = 3;
                    section.data(4).dtTransOffset = 3;

                    ;% rtP.P_dis_max
                    section.data(5).logicalSrcIdx = 4;
                    section.data(5).dtTransOffset = 4;

                    ;% rtP.Q_nom
                    section.data(6).logicalSrcIdx = 5;
                    section.data(6).dtTransOffset = 5;

                    ;% rtP.R_gas
                    section.data(7).logicalSrcIdx = 6;
                    section.data(7).dtTransOffset = 6;

                    ;% rtP.SOC_max
                    section.data(8).logicalSrcIdx = 7;
                    section.data(8).dtTransOffset = 7;

                    ;% rtP.SOC_min
                    section.data(9).logicalSrcIdx = 8;
                    section.data(9).dtTransOffset = 8;

                    ;% rtP.SOH_min
                    section.data(10).logicalSrcIdx = 9;
                    section.data(10).dtTransOffset = 9;

                    ;% rtP.Tref_K
                    section.data(11).logicalSrcIdx = 10;
                    section.data(11).dtTransOffset = 10;

                    ;% rtP.Tref_cal
                    section.data(12).logicalSrcIdx = 11;
                    section.data(12).dtTransOffset = 11;

                    ;% rtP.Ua_ref
                    section.data(13).logicalSrcIdx = 12;
                    section.data(13).dtTransOffset = 12;

                    ;% rtP.V_nom
                    section.data(14).logicalSrcIdx = 13;
                    section.data(14).dtTransOffset = 13;

                    ;% rtP.a_montes
                    section.data(15).logicalSrcIdx = 14;
                    section.data(15).dtTransOffset = 14;

                    ;% rtP.alpha_cal
                    section.data(16).logicalSrcIdx = 15;
                    section.data(16).dtTransOffset = 15;

                    ;% rtP.eta_ch
                    section.data(17).logicalSrcIdx = 16;
                    section.data(17).dtTransOffset = 16;

                    ;% rtP.eta_dis
                    section.data(18).logicalSrcIdx = 17;
                    section.data(18).dtTransOffset = 17;

                    ;% rtP.k0_cal
                    section.data(19).logicalSrcIdx = 18;
                    section.data(19).dtTransOffset = 18;

                    ;% rtP.kCch
                    section.data(20).logicalSrcIdx = 19;
                    section.data(20).dtTransOffset = 19;

                    ;% rtP.kCdch
                    section.data(21).logicalSrcIdx = 20;
                    section.data(21).dtTransOffset = 20;

                    ;% rtP.kDODc
                    section.data(22).logicalSrcIdx = 21;
                    section.data(22).dtTransOffset = 21;

                    ;% rtP.kT
                    section.data(23).logicalSrcIdx = 22;
                    section.data(23).dtTransOffset = 22;

                    ;% rtP.kcal_ref
                    section.data(24).logicalSrcIdx = 23;
                    section.data(24).dtTransOffset = 23;

                    ;% rtP.kcyc
                    section.data(25).logicalSrcIdx = 24;
                    section.data(25).dtTransOffset = 24;

                    ;% rtP.kmSOC
                    section.data(26).logicalSrcIdx = 25;
                    section.data(26).dtTransOffset = 25;

                    ;% rtP.mSOCref
                    section.data(27).logicalSrcIdx = 26;
                    section.data(27).dtTransOffset = 26;

                    ;% rtP.FromWorkspace_Time0
                    section.data(28).logicalSrcIdx = 27;
                    section.data(28).dtTransOffset = 27;

                    ;% rtP.FromWorkspace_Data0
                    section.data(29).logicalSrcIdx = 28;
                    section.data(29).dtTransOffset = 8787;

                    ;% rtP.FromWorkspace1_Time0
                    section.data(30).logicalSrcIdx = 29;
                    section.data(30).dtTransOffset = 17547;

                    ;% rtP.FromWorkspace1_Data0
                    section.data(31).logicalSrcIdx = 30;
                    section.data(31).dtTransOffset = 26307;

                    ;% rtP.Memory_InitialCondition
                    section.data(32).logicalSrcIdx = 31;
                    section.data(32).dtTransOffset = 35067;

                    ;% rtP.Memory10_InitialCondition
                    section.data(33).logicalSrcIdx = 32;
                    section.data(33).dtTransOffset = 35068;

                    ;% rtP.DiscreteTimeIntegrator_gainval
                    section.data(34).logicalSrcIdx = 33;
                    section.data(34).dtTransOffset = 35069;

                    ;% rtP.DiscreteTimeIntegrator_IC
                    section.data(35).logicalSrcIdx = 34;
                    section.data(35).dtTransOffset = 35070;

                    ;% rtP.Memory9_InitialCondition
                    section.data(36).logicalSrcIdx = 35;
                    section.data(36).dtTransOffset = 35071;

                    ;% rtP.Memory8_InitialCondition
                    section.data(37).logicalSrcIdx = 36;
                    section.data(37).dtTransOffset = 35072;

                    ;% rtP.Memory7_InitialCondition
                    section.data(38).logicalSrcIdx = 37;
                    section.data(38).dtTransOffset = 35073;

                    ;% rtP.Memory6_InitialCondition
                    section.data(39).logicalSrcIdx = 38;
                    section.data(39).dtTransOffset = 35074;

                    ;% rtP.Memory5_InitialCondition
                    section.data(40).logicalSrcIdx = 39;
                    section.data(40).dtTransOffset = 35075;

                    ;% rtP.Memory4_InitialCondition
                    section.data(41).logicalSrcIdx = 40;
                    section.data(41).dtTransOffset = 35076;

                    ;% rtP.Memory3_InitialCondition
                    section.data(42).logicalSrcIdx = 41;
                    section.data(42).dtTransOffset = 35077;

                    ;% rtP.Memory2_InitialCondition
                    section.data(43).logicalSrcIdx = 42;
                    section.data(43).dtTransOffset = 35078;

                    ;% rtP.DiscreteTimeIntegrator1_gainval
                    section.data(44).logicalSrcIdx = 43;
                    section.data(44).dtTransOffset = 35079;

                    ;% rtP.DiscreteTimeIntegrator1_IC
                    section.data(45).logicalSrcIdx = 44;
                    section.data(45).dtTransOffset = 35080;

                    ;% rtP.Memory1_InitialCondition
                    section.data(46).logicalSrcIdx = 45;
                    section.data(46).dtTransOffset = 35081;

                    ;% rtP.Q_gainval
                    section.data(47).logicalSrcIdx = 46;
                    section.data(47).dtTransOffset = 35082;

                    ;% rtP.Q_IC
                    section.data(48).logicalSrcIdx = 47;
                    section.data(48).dtTransOffset = 35083;

                    ;% rtP.Q_UpperSat
                    section.data(49).logicalSrcIdx = 48;
                    section.data(49).dtTransOffset = 35084;

                    ;% rtP.Q_LowerSat
                    section.data(50).logicalSrcIdx = 49;
                    section.data(50).dtTransOffset = 35085;

                    ;% rtP.Constant_Value
                    section.data(51).logicalSrcIdx = 50;
                    section.data(51).dtTransOffset = 35086;

                    ;% rtP.Constant1_Value
                    section.data(52).logicalSrcIdx = 51;
                    section.data(52).dtTransOffset = 35087;

            nTotData = nTotData + section.nData;
            paramMap.sections(1) = section;
            clear section


            ;%
            ;% Non-auto Data (parameter)
            ;%


        ;%
        ;% Add final counts to struct.
        ;%
        paramMap.nTotData = nTotData;



    ;%**************************
    ;% Create Block Output Map *
    ;%**************************
    
        nTotData      = 0; %add to this count as we go
        nTotSects     = 1;
        sectIdxOffset = 0;

        ;%
        ;% Define dummy sections & preallocate arrays
        ;%
        dumSection.nData = -1;
        dumSection.data  = [];

        dumData.logicalSrcIdx = -1;
        dumData.dtTransOffset = -1;

        ;%
        ;% Init/prealloc sigMap
        ;%
        sigMap.nSections           = nTotSects;
        sigMap.sectIdxOffset       = sectIdxOffset;
            sigMap.sections(nTotSects) = dumSection; %prealloc
        sigMap.nTotData            = -1;

        ;%
        ;% Auto data (rtB)
        ;%
            section.nData     = 30;
            section.data(30)  = dumData; %prealloc

                    ;% rtB.gfjl5uvadj
                    section.data(1).logicalSrcIdx = 0;
                    section.data(1).dtTransOffset = 0;

                    ;% rtB.kmcjjgcbwm
                    section.data(2).logicalSrcIdx = 1;
                    section.data(2).dtTransOffset = 1;

                    ;% rtB.nvs4zgqg5q
                    section.data(3).logicalSrcIdx = 2;
                    section.data(3).dtTransOffset = 2;

                    ;% rtB.ljhaxh4oj5
                    section.data(4).logicalSrcIdx = 3;
                    section.data(4).dtTransOffset = 3;

                    ;% rtB.c2uoafqle4
                    section.data(5).logicalSrcIdx = 4;
                    section.data(5).dtTransOffset = 4;

                    ;% rtB.ab2b224ruk
                    section.data(6).logicalSrcIdx = 5;
                    section.data(6).dtTransOffset = 5;

                    ;% rtB.apklv45iea
                    section.data(7).logicalSrcIdx = 6;
                    section.data(7).dtTransOffset = 6;

                    ;% rtB.lkqisxo3wh
                    section.data(8).logicalSrcIdx = 7;
                    section.data(8).dtTransOffset = 7;

                    ;% rtB.drht0m2wcu
                    section.data(9).logicalSrcIdx = 8;
                    section.data(9).dtTransOffset = 8;

                    ;% rtB.ktvi0iztpb
                    section.data(10).logicalSrcIdx = 9;
                    section.data(10).dtTransOffset = 9;

                    ;% rtB.l1ehz3xtne
                    section.data(11).logicalSrcIdx = 10;
                    section.data(11).dtTransOffset = 10;

                    ;% rtB.gd10qvi0hb
                    section.data(12).logicalSrcIdx = 11;
                    section.data(12).dtTransOffset = 11;

                    ;% rtB.emhm1vcgl4
                    section.data(13).logicalSrcIdx = 12;
                    section.data(13).dtTransOffset = 12;

                    ;% rtB.izewb3fbhm
                    section.data(14).logicalSrcIdx = 13;
                    section.data(14).dtTransOffset = 13;

                    ;% rtB.llsn45poan
                    section.data(15).logicalSrcIdx = 14;
                    section.data(15).dtTransOffset = 14;

                    ;% rtB.k3cmfktp1r
                    section.data(16).logicalSrcIdx = 15;
                    section.data(16).dtTransOffset = 15;

                    ;% rtB.acbl5n1qaz
                    section.data(17).logicalSrcIdx = 18;
                    section.data(17).dtTransOffset = 16;

                    ;% rtB.hm2dlit4ls
                    section.data(18).logicalSrcIdx = 20;
                    section.data(18).dtTransOffset = 17;

                    ;% rtB.jwrv1jc5tm
                    section.data(19).logicalSrcIdx = 21;
                    section.data(19).dtTransOffset = 18;

                    ;% rtB.pamvsakvqt
                    section.data(20).logicalSrcIdx = 22;
                    section.data(20).dtTransOffset = 19;

                    ;% rtB.ht2kyzk05c
                    section.data(21).logicalSrcIdx = 23;
                    section.data(21).dtTransOffset = 20;

                    ;% rtB.anem5cqywe
                    section.data(22).logicalSrcIdx = 24;
                    section.data(22).dtTransOffset = 21;

                    ;% rtB.n35ghbysje
                    section.data(23).logicalSrcIdx = 25;
                    section.data(23).dtTransOffset = 22;

                    ;% rtB.lrgn12tt5s
                    section.data(24).logicalSrcIdx = 26;
                    section.data(24).dtTransOffset = 23;

                    ;% rtB.danczs523w
                    section.data(25).logicalSrcIdx = 27;
                    section.data(25).dtTransOffset = 24;

                    ;% rtB.kslhz20rry
                    section.data(26).logicalSrcIdx = 28;
                    section.data(26).dtTransOffset = 25;

                    ;% rtB.b5okag1uwe
                    section.data(27).logicalSrcIdx = 29;
                    section.data(27).dtTransOffset = 26;

                    ;% rtB.itatj05zcw
                    section.data(28).logicalSrcIdx = 30;
                    section.data(28).dtTransOffset = 27;

                    ;% rtB.aaksx3pjru
                    section.data(29).logicalSrcIdx = 31;
                    section.data(29).dtTransOffset = 28;

                    ;% rtB.ezqw1dn0pv
                    section.data(30).logicalSrcIdx = 32;
                    section.data(30).dtTransOffset = 29;

            nTotData = nTotData + section.nData;
            sigMap.sections(1) = section;
            clear section


            ;%
            ;% Non-auto Data (signal)
            ;%


        ;%
        ;% Add final counts to struct.
        ;%
        sigMap.nTotData = nTotData;



    ;%*******************
    ;% Create DWork Map *
    ;%*******************
    
        nTotData      = 0; %add to this count as we go
        nTotSects     = 5;
        sectIdxOffset = 1;

        ;%
        ;% Define dummy sections & preallocate arrays
        ;%
        dumSection.nData = -1;
        dumSection.data  = [];

        dumData.logicalSrcIdx = -1;
        dumData.dtTransOffset = -1;

        ;%
        ;% Init/prealloc dworkMap
        ;%
        dworkMap.nSections           = nTotSects;
        dworkMap.sectIdxOffset       = sectIdxOffset;
            dworkMap.sections(nTotSects) = dumSection; %prealloc
        dworkMap.nTotData            = -1;

        ;%
        ;% Auto data (rtDW)
        ;%
            section.nData     = 14;
            section.data(14)  = dumData; %prealloc

                    ;% rtDW.f3goquxbks
                    section.data(1).logicalSrcIdx = 0;
                    section.data(1).dtTransOffset = 0;

                    ;% rtDW.o4rhvmic4i
                    section.data(2).logicalSrcIdx = 1;
                    section.data(2).dtTransOffset = 1;

                    ;% rtDW.jmly0jp5wg
                    section.data(3).logicalSrcIdx = 2;
                    section.data(3).dtTransOffset = 2;

                    ;% rtDW.a0zxvagfzg
                    section.data(4).logicalSrcIdx = 3;
                    section.data(4).dtTransOffset = 3;

                    ;% rtDW.kjcssqsgiy
                    section.data(5).logicalSrcIdx = 4;
                    section.data(5).dtTransOffset = 4;

                    ;% rtDW.npfta3gsnz
                    section.data(6).logicalSrcIdx = 5;
                    section.data(6).dtTransOffset = 5;

                    ;% rtDW.bkjs4plmiw
                    section.data(7).logicalSrcIdx = 6;
                    section.data(7).dtTransOffset = 6;

                    ;% rtDW.lgcqjznrs4
                    section.data(8).logicalSrcIdx = 7;
                    section.data(8).dtTransOffset = 7;

                    ;% rtDW.g4elmb3m3d
                    section.data(9).logicalSrcIdx = 8;
                    section.data(9).dtTransOffset = 8;

                    ;% rtDW.aihvbm54nh
                    section.data(10).logicalSrcIdx = 9;
                    section.data(10).dtTransOffset = 9;

                    ;% rtDW.pg0uf0tjmq
                    section.data(11).logicalSrcIdx = 10;
                    section.data(11).dtTransOffset = 10;

                    ;% rtDW.el3rkvzu35
                    section.data(12).logicalSrcIdx = 11;
                    section.data(12).dtTransOffset = 11;

                    ;% rtDW.hgyvxtnudh
                    section.data(13).logicalSrcIdx = 12;
                    section.data(13).dtTransOffset = 12;

                    ;% rtDW.bub2n2zpek
                    section.data(14).logicalSrcIdx = 13;
                    section.data(14).dtTransOffset = 13;

            nTotData = nTotData + section.nData;
            dworkMap.sections(1) = section;
            clear section

            section.nData     = 3;
            section.data(3)  = dumData; %prealloc

                    ;% rtDW.oquds51bjd.TimePtr
                    section.data(1).logicalSrcIdx = 14;
                    section.data(1).dtTransOffset = 0;

                    ;% rtDW.l42v1z4ttb.TimePtr
                    section.data(2).logicalSrcIdx = 15;
                    section.data(2).dtTransOffset = 1;

                    ;% rtDW.epnl41f4ab.AQHandles
                    section.data(3).logicalSrcIdx = 16;
                    section.data(3).dtTransOffset = 2;

            nTotData = nTotData + section.nData;
            dworkMap.sections(2) = section;
            clear section

            section.nData     = 5;
            section.data(5)  = dumData; %prealloc

                    ;% rtDW.o33bfbbal0
                    section.data(1).logicalSrcIdx = 17;
                    section.data(1).dtTransOffset = 0;

                    ;% rtDW.kxeyldgybk
                    section.data(2).logicalSrcIdx = 18;
                    section.data(2).dtTransOffset = 1;

                    ;% rtDW.hefs3t3wtj
                    section.data(3).logicalSrcIdx = 19;
                    section.data(3).dtTransOffset = 2;

                    ;% rtDW.hewzuyypfk
                    section.data(4).logicalSrcIdx = 20;
                    section.data(4).dtTransOffset = 3;

                    ;% rtDW.mpbenfv0mh
                    section.data(5).logicalSrcIdx = 21;
                    section.data(5).dtTransOffset = 4;

            nTotData = nTotData + section.nData;
            dworkMap.sections(3) = section;
            clear section

            section.nData     = 2;
            section.data(2)  = dumData; %prealloc

                    ;% rtDW.muknhfqzdo.PrevIndex
                    section.data(1).logicalSrcIdx = 22;
                    section.data(1).dtTransOffset = 0;

                    ;% rtDW.dsjkow15mf.PrevIndex
                    section.data(2).logicalSrcIdx = 23;
                    section.data(2).dtTransOffset = 1;

            nTotData = nTotData + section.nData;
            dworkMap.sections(4) = section;
            clear section

            section.nData     = 5;
            section.data(5)  = dumData; %prealloc

                    ;% rtDW.feh2m5jwzm
                    section.data(1).logicalSrcIdx = 24;
                    section.data(1).dtTransOffset = 0;

                    ;% rtDW.oo1v0nx2o1
                    section.data(2).logicalSrcIdx = 25;
                    section.data(2).dtTransOffset = 1;

                    ;% rtDW.jouixdcorf
                    section.data(3).logicalSrcIdx = 26;
                    section.data(3).dtTransOffset = 2;

                    ;% rtDW.jsg52rnue1
                    section.data(4).logicalSrcIdx = 27;
                    section.data(4).dtTransOffset = 3;

                    ;% rtDW.pl5fmt4wih
                    section.data(5).logicalSrcIdx = 28;
                    section.data(5).dtTransOffset = 4;

            nTotData = nTotData + section.nData;
            dworkMap.sections(5) = section;
            clear section


            ;%
            ;% Non-auto Data (dwork)
            ;%


        ;%
        ;% Add final counts to struct.
        ;%
        dworkMap.nTotData = nTotData;



    ;%
    ;% Add individual maps to base struct.
    ;%

    targMap.paramMap  = paramMap;
    targMap.signalMap = sigMap;
    targMap.dworkMap  = dworkMap;

    ;%
    ;% Add checksums to base struct.
    ;%


    targMap.checksum0 = 3438260156;
    targMap.checksum1 = 1447167630;
    targMap.checksum2 = 1712335604;
    targMap.checksum3 = 163470120;

