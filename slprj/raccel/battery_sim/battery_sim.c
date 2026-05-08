#include "battery_sim.h"
#include "rtwtypes.h"
#include "mwmathutil.h"
#include "battery_sim_private.h"
#include "rt_logging_mmi.h"
#include "battery_sim_capi.h"
#include "battery_sim_dt.h"
extern void * CreateDiagnosticAsVoidPtr_wrapper ( const char * id , int nargs
, ... ) ; extern ssExecutionInfo gblExecutionInfo ; RTWExtModeInfo *
gblRTWExtModeInfo = NULL ; void raccelForceExtModeShutdown ( boolean_T
extModeStartPktReceived ) { if ( ! extModeStartPktReceived ) { boolean_T
stopRequested = false ; rtExtModeWaitForStartPkt ( gblRTWExtModeInfo , 4 , &
stopRequested ) ; } rtExtModeShutdown ( 4 ) ; }
#include "slsv_diagnostic_codegen_c_api.h"
#include "slsa_engine_exec.h"
#ifdef RSIM_WITH_SOLVER_MULTITASKING
boolean_T gbl_raccel_isMultitasking = 1 ;
#else
boolean_T gbl_raccel_isMultitasking = 0 ;
#endif
boolean_T gbl_raccel_tid01eq = 0 ; int_T gbl_raccel_NumST = 5 ; const char_T
* gbl_raccel_Version = "24.1 (R2024a) 19-Nov-2023" ; void
raccel_setup_MMIStateLog ( SimStruct * S ) {
#ifdef UseMMIDataLogging
rt_FillStateSigInfoFromMMI ( ssGetRTWLogInfo ( S ) , & ssGetErrorStatus ( S )
) ;
#else
UNUSED_PARAMETER ( S ) ;
#endif
} static DataMapInfo rt_dataMapInfo ; DataMapInfo * rt_dataMapInfoPtr = &
rt_dataMapInfo ; rtwCAPI_ModelMappingInfo * rt_modelMapInfoPtr = & (
rt_dataMapInfo . mmi ) ; int_T enableFcnCallFlag [ ] = { 1 , 1 , 1 , 1 , 1 }
; const char * raccelLoadInputsAndAperiodicHitTimes ( SimStruct * S , const
char * inportFileName , int * matFileFormat ) { return
rt_RAccelReadInportsMatFile ( S , inportFileName , matFileFormat ) ; }
#include "simstruc.h"
#include "fixedpoint.h"
#include "slsa_engine_exec.h"
#include "simtarget/slSimTgtSLExecSimBridge.h"
#define pyjn4s2eda (-1)
B rtB ; DW rtDW ; static SimStruct model_S ; SimStruct * const rtS = &
model_S ; void MdlInitialize ( void ) { rtDW . a0zxvagfzg = rtP .
Memory_InitialCondition ; rtDW . kjcssqsgiy = rtP . Memory10_InitialCondition
; rtDW . f3goquxbks = rtP . DiscreteTimeIntegrator_IC ; rtDW . npfta3gsnz =
rtP . Memory9_InitialCondition ; rtDW . bkjs4plmiw = rtP .
Memory8_InitialCondition ; rtDW . lgcqjznrs4 = rtP . Memory7_InitialCondition
; rtDW . g4elmb3m3d = rtP . Memory6_InitialCondition ; rtDW . aihvbm54nh =
rtP . Memory5_InitialCondition ; rtDW . pg0uf0tjmq = rtP .
Memory4_InitialCondition ; rtDW . el3rkvzu35 = rtP . Memory3_InitialCondition
; rtDW . hgyvxtnudh = rtP . Memory2_InitialCondition ; rtDW . o4rhvmic4i =
rtP . DiscreteTimeIntegrator1_IC ; rtDW . bub2n2zpek = rtP .
Memory1_InitialCondition ; rtDW . jmly0jp5wg = rtP . Q_IC ; rtDW . feh2m5jwzm
= false ; rtDW . o33bfbbal0 = pyjn4s2eda ; rtDW . oo1v0nx2o1 = false ; rtDW .
kxeyldgybk = pyjn4s2eda ; rtDW . jsg52rnue1 = false ; rtDW . hewzuyypfk =
pyjn4s2eda ; rtDW . jouixdcorf = false ; rtDW . hefs3t3wtj = pyjn4s2eda ;
rtDW . pl5fmt4wih = false ; rtDW . mpbenfv0mh = pyjn4s2eda ; } void MdlStart
( void ) { { bool externalInputIsInDatasetFormat = false ; void *
pISigstreamManager = rt_GetISigstreamManager ( rtS ) ;
rtwISigstreamManagerGetInputIsInDatasetFormat ( pISigstreamManager , &
externalInputIsInDatasetFormat ) ; if ( externalInputIsInDatasetFormat ) { }
} { { { bool isStreamoutAlreadyRegistered = false ; { sdiSignalSourceInfoU
srcInfo ; sdiLabelU sigName = sdiGetLabelFromChars ( "" ) ; sdiLabelU
blockPath = sdiGetLabelFromChars ( "battery_sim/To Workspace" ) ; sdiLabelU
blockSID = sdiGetLabelFromChars ( "" ) ; sdiLabelU subPath =
sdiGetLabelFromChars ( "" ) ; const char_T * leafUnits [ 3 ] = { "" , "" , ""
} ; sdiVirtualBusLeafElementInfoU leafElInfo [ 3 ] ; int_T childDimsArray0 [
1 ] = { 1 } ; int_T childDimsArray1 [ 1 ] = { 1 } ; int_T childDimsArray2 [ 1
] = { 1 } ; { sdiAsyncRepoDataTypeHandle hDT =
sdiAsyncRepoGetBuiltInDataTypeHandle ( DATA_TYPE_DOUBLE ) ; leafElInfo [ 0 ]
. hDataType = hDT ; leafElInfo [ 0 ] . signalName = sdiGetLabelFromChars (
".P_bess" ) ; leafElInfo [ 0 ] . dims . nDims = 1 ; leafElInfo [ 0 ] . dims .
dimensions = childDimsArray0 ; leafElInfo [ 0 ] . dimsMode =
DIMENSIONS_MODE_FIXED ; leafElInfo [ 0 ] . complexity = REAL ; leafElInfo [ 0
] . isLinearInterp = 1 ; leafElInfo [ 0 ] . units = leafUnits [ 0 ] ; } {
sdiAsyncRepoDataTypeHandle hDT = sdiAsyncRepoGetBuiltInDataTypeHandle (
DATA_TYPE_DOUBLE ) ; leafElInfo [ 1 ] . hDataType = hDT ; leafElInfo [ 1 ] .
signalName = sdiGetLabelFromChars ( ".SOH" ) ; leafElInfo [ 1 ] . dims .
nDims = 1 ; leafElInfo [ 1 ] . dims . dimensions = childDimsArray1 ;
leafElInfo [ 1 ] . dimsMode = DIMENSIONS_MODE_FIXED ; leafElInfo [ 1 ] .
complexity = REAL ; leafElInfo [ 1 ] . isLinearInterp = 1 ; leafElInfo [ 1 ]
. units = leafUnits [ 1 ] ; } { sdiAsyncRepoDataTypeHandle hDT =
sdiAsyncRepoGetBuiltInDataTypeHandle ( DATA_TYPE_DOUBLE ) ; leafElInfo [ 2 ]
. hDataType = hDT ; leafElInfo [ 2 ] . signalName = sdiGetLabelFromChars (
".V_terminal" ) ; leafElInfo [ 2 ] . dims . nDims = 1 ; leafElInfo [ 2 ] .
dims . dimensions = childDimsArray2 ; leafElInfo [ 2 ] . dimsMode =
DIMENSIONS_MODE_FIXED ; leafElInfo [ 2 ] . complexity = REAL ; leafElInfo [ 2
] . isLinearInterp = 1 ; leafElInfo [ 2 ] . units = leafUnits [ 2 ] ; }
srcInfo . numBlockPathElems = 1 ; srcInfo . fullBlockPath = ( sdiFullBlkPathU
) & blockPath ; srcInfo . SID = ( sdiSignalIDU ) & blockSID ; srcInfo .
subPath = subPath ; srcInfo . portIndex = 0 + 1 ; srcInfo . signalName =
sigName ; srcInfo . sigSourceUUID = 0 ;
sdiCreateAsyncQueuesForVirtualBusWithExportSettings ( & srcInfo ,
rt_dataMapInfo . mmi . InstanceMap . fullPath ,
"d40be9a7-1860-42f6-9dc7-ad7f6217f741" , 3 , leafElInfo , & rtDW . epnl41f4ab
. AQHandles [ 0 ] , 1 , 0 , "Bus\nCreator" , "" , "Bus\nCreator" ) ;
slsaCacheDWorkDataForSimTargetOP ( rtS , & rtDW . epnl41f4ab . AQHandles [ 0
] , 3 * sizeof ( & rtDW . epnl41f4ab . AQHandles [ 0 ] ) ) ; if ( rtDW .
epnl41f4ab . AQHandles [ 0 ] ) { sdiLabelU loggedName = sdiGetLabelFromChars
( "Bus\nCreator" ) ; sdiLabelU origSigName = sdiGetLabelFromChars ( "" ) ;
sdiLabelU propName = sdiGetLabelFromChars ( "Bus\nCreator" ) ;
sdiSetSignalSampleTimeString ( rtDW . epnl41f4ab . AQHandles [ 0 ] ,
"Continuous" , 0.0 , ssGetTFinal ( rtS ) ) ; sdiSetSignalRefRate ( rtDW .
epnl41f4ab . AQHandles [ 0 ] , 0.0 ) ; sdiSetRunStartTime ( rtDW . epnl41f4ab
. AQHandles [ 0 ] , ssGetTaskTime ( rtS , 0 ) ) ;
sdiAsyncRepoSetSignalExportSettings ( rtDW . epnl41f4ab . AQHandles [ 0 ] , 1
, 0 ) ; sdiAsyncRepoSetSignalExportName ( rtDW . epnl41f4ab . AQHandles [ 0 ]
, loggedName , origSigName , propName ) ; sdiAsyncRepoSetBlockPathDomain (
rtDW . epnl41f4ab . AQHandles [ 0 ] ) ; sdiSetSignalSampleTimeString ( rtDW .
epnl41f4ab . AQHandles [ 1 ] , "Continuous" , 0.0 , ssGetTFinal ( rtS ) ) ;
sdiSetSignalRefRate ( rtDW . epnl41f4ab . AQHandles [ 1 ] , 0.0 ) ;
sdiSetRunStartTime ( rtDW . epnl41f4ab . AQHandles [ 1 ] , ssGetTaskTime (
rtS , 0 ) ) ; sdiAsyncRepoSetSignalExportSettings ( rtDW . epnl41f4ab .
AQHandles [ 1 ] , 1 , 0 ) ; sdiAsyncRepoSetSignalExportName ( rtDW .
epnl41f4ab . AQHandles [ 1 ] , loggedName , origSigName , propName ) ;
sdiAsyncRepoSetBlockPathDomain ( rtDW . epnl41f4ab . AQHandles [ 1 ] ) ;
sdiSetSignalSampleTimeString ( rtDW . epnl41f4ab . AQHandles [ 2 ] ,
"Continuous" , 0.0 , ssGetTFinal ( rtS ) ) ; sdiSetSignalRefRate ( rtDW .
epnl41f4ab . AQHandles [ 2 ] , 0.0 ) ; sdiSetRunStartTime ( rtDW . epnl41f4ab
. AQHandles [ 2 ] , ssGetTaskTime ( rtS , 0 ) ) ;
sdiAsyncRepoSetSignalExportSettings ( rtDW . epnl41f4ab . AQHandles [ 2 ] , 1
, 0 ) ; sdiAsyncRepoSetSignalExportName ( rtDW . epnl41f4ab . AQHandles [ 2 ]
, loggedName , origSigName , propName ) ; sdiAsyncRepoSetBlockPathDomain (
rtDW . epnl41f4ab . AQHandles [ 2 ] ) ; sdiFreeLabel ( loggedName ) ;
sdiFreeLabel ( origSigName ) ; sdiFreeLabel ( propName ) ; } sdiFreeLabel (
sigName ) ; sdiFreeLabel ( blockPath ) ; sdiFreeLabel ( blockSID ) ;
sdiFreeLabel ( subPath ) ; sdiFreeName ( leafElInfo [ 0 ] . signalName ) ;
sdiFreeName ( leafElInfo [ 1 ] . signalName ) ; sdiFreeName ( leafElInfo [ 2
] . signalName ) ; } if ( ! isStreamoutAlreadyRegistered ) { { sdiLabelU
varName = sdiGetLabelFromChars ( "outputs" ) ; sdiRegisterWksVariable ( rtDW
. epnl41f4ab . AQHandles [ 0 ] , varName , "timeseries" ) ; sdiFreeLabel (
varName ) ; } } } } } { FWksInfo * fromwksInfo ; if ( ( fromwksInfo = (
FWksInfo * ) calloc ( 1 , sizeof ( FWksInfo ) ) ) == ( NULL ) ) {
ssSetErrorStatus ( rtS ,
"from workspace STRING(Name) memory allocation error" ) ; } else {
fromwksInfo -> origWorkspaceVarName = "Ppv_ws" ; fromwksInfo ->
origDataTypeId = 0 ; fromwksInfo -> origIsComplex = 0 ; fromwksInfo ->
origWidth = 1 ; fromwksInfo -> origElSize = sizeof ( real_T ) ; fromwksInfo
-> data = ( void * ) rtP . FromWorkspace_Data0 ; fromwksInfo -> nDataPoints =
8760 ; fromwksInfo -> time = ( double * ) rtP . FromWorkspace_Time0 ; rtDW .
oquds51bjd . TimePtr = fromwksInfo -> time ; rtDW . oquds51bjd . DataPtr =
fromwksInfo -> data ; rtDW . oquds51bjd . RSimInfoPtr = fromwksInfo ; } rtDW
. muknhfqzdo . PrevIndex = 0 ; } { FWksInfo * fromwksInfo ; if ( (
fromwksInfo = ( FWksInfo * ) calloc ( 1 , sizeof ( FWksInfo ) ) ) == ( NULL )
) { ssSetErrorStatus ( rtS ,
"from workspace STRING(Name) memory allocation error" ) ; } else {
fromwksInfo -> origWorkspaceVarName = "Pload_ws" ; fromwksInfo ->
origDataTypeId = 0 ; fromwksInfo -> origIsComplex = 0 ; fromwksInfo ->
origWidth = 1 ; fromwksInfo -> origElSize = sizeof ( real_T ) ; fromwksInfo
-> data = ( void * ) rtP . FromWorkspace1_Data0 ; fromwksInfo -> nDataPoints
= 8760 ; fromwksInfo -> time = ( double * ) rtP . FromWorkspace1_Time0 ; rtDW
. l42v1z4ttb . TimePtr = fromwksInfo -> time ; rtDW . l42v1z4ttb . DataPtr =
fromwksInfo -> data ; rtDW . l42v1z4ttb . RSimInfoPtr = fromwksInfo ; } rtDW
. dsjkow15mf . PrevIndex = 0 ; } MdlInitialize ( ) ; } void MdlOutputs (
int_T tid ) { real_T j5lp041upu ; real_T ixh1ap3gi4 ; real_T Cch_i ; real_T
Cdis_i ; real_T Fvirt_prev ; real_T Ireq ; real_T OCV_ref ; real_T Q_cur ;
real_T delta_i ; real_T newdir ; real_T oxbk5ugwgf ; real_T seg_Ah_dis ;
real_T seg_dt_dis ; real_T xa ; int32_T high_i ; int32_T low_i ; int32_T
low_ip1 ; int32_T mid_i ; static const real_T c [ 13 ] = { 0.0 , 0.05 , 0.1 ,
0.2 , 0.3 , 0.4 , 0.5 , 0.6 , 0.7 , 0.8 , 0.9 , 0.95 , 1.0 } ; static const
real_T b [ 48 ] = { - 1428.5714285714271 , - 68.571428571428683 ,
23.99999999999994 , - 5.9999999999998668 , - 5.9999999999998268 ,
3.9999999999999307 , - 6.6666666666664787 , 6.6666666666666234 , -
2.6666666666665155 , 9.9574468085107952 , 67.466150870405116 , -
356.3636363636345 , - 28.571428571428669 , - 25.14285714285716 , -
4.399999999999995 , 1.1999999999999726 , 0.59999999999998177 , -
0.799999999999986 , 0.66666666666664776 , - 0.99999999999999356 ,
0.93333333333329715 , - 0.39574468085109227 , 3.4352030947777 ,
63.636363636363477 , 17.000000000000004 , 3.4285714285714315 ,
0.4000000000000003 , 0.23999999999999952 , 0.29999999999999805 ,
0.23999999999999952 , 0.20000000000000023 , 0.13333333333333547 ,
0.13333333333333541 , 0.23999999999999941 , 0.45957446808510471 ,
1.3090909090909113 , 2.5 , 3.1 , 3.2 , 3.22 , 3.25 , 3.28 , 3.3 , 3.32 , 3.33
, 3.35 , 3.38 , 3.42 } ; int32_T exitg1 ; { real_T * pDataValues = ( real_T *
) rtDW . oquds51bjd . DataPtr ; real_T * pTimeValues = ( real_T * ) rtDW .
oquds51bjd . TimePtr ; int_T currTimeIndex = rtDW . muknhfqzdo . PrevIndex ;
real_T t = ssGetTaskTime ( rtS , 0 ) ; int numPoints , lastPoint ; FWksInfo *
fromwksInfo = ( FWksInfo * ) rtDW . oquds51bjd . RSimInfoPtr ; numPoints =
fromwksInfo -> nDataPoints ; lastPoint = numPoints - 1 ; if ( t <=
pTimeValues [ 0 ] ) { currTimeIndex = 0 ; } else if ( t >= pTimeValues [
lastPoint ] ) { currTimeIndex = lastPoint - 1 ; } else { if ( t < pTimeValues
[ currTimeIndex ] ) { while ( t < pTimeValues [ currTimeIndex ] ) {
currTimeIndex -- ; } } else { while ( t >= pTimeValues [ currTimeIndex + 1 ]
) { currTimeIndex ++ ; } } } rtDW . muknhfqzdo . PrevIndex = currTimeIndex ;
{ real_T t1 = pTimeValues [ currTimeIndex ] ; real_T t2 = pTimeValues [
currTimeIndex + 1 ] ; if ( t1 == t2 ) { if ( t < t1 ) { j5lp041upu =
pDataValues [ currTimeIndex ] ; } else { j5lp041upu = pDataValues [
currTimeIndex + 1 ] ; } } else { real_T f1 = ( t2 - t ) / ( t2 - t1 ) ;
real_T f2 = 1.0 - f1 ; real_T d1 ; real_T d2 ; int_T TimeIndex =
currTimeIndex ; d1 = pDataValues [ TimeIndex ] ; d2 = pDataValues [ TimeIndex
+ 1 ] ; j5lp041upu = ( real_T ) rtInterpolate ( d1 , d2 , f1 , f2 ) ;
pDataValues += numPoints ; } } } { real_T * pDataValues = ( real_T * ) rtDW .
l42v1z4ttb . DataPtr ; real_T * pTimeValues = ( real_T * ) rtDW . l42v1z4ttb
. TimePtr ; int_T currTimeIndex = rtDW . dsjkow15mf . PrevIndex ; real_T t =
ssGetTaskTime ( rtS , 0 ) ; int numPoints , lastPoint ; FWksInfo *
fromwksInfo = ( FWksInfo * ) rtDW . l42v1z4ttb . RSimInfoPtr ; numPoints =
fromwksInfo -> nDataPoints ; lastPoint = numPoints - 1 ; if ( t <=
pTimeValues [ 0 ] ) { currTimeIndex = 0 ; } else if ( t >= pTimeValues [
lastPoint ] ) { currTimeIndex = lastPoint - 1 ; } else { if ( t < pTimeValues
[ currTimeIndex ] ) { while ( t < pTimeValues [ currTimeIndex ] ) {
currTimeIndex -- ; } } else { while ( t >= pTimeValues [ currTimeIndex + 1 ]
) { currTimeIndex ++ ; } } } rtDW . dsjkow15mf . PrevIndex = currTimeIndex ;
{ real_T t1 = pTimeValues [ currTimeIndex ] ; real_T t2 = pTimeValues [
currTimeIndex + 1 ] ; if ( t1 == t2 ) { if ( t < t1 ) { ixh1ap3gi4 =
pDataValues [ currTimeIndex ] ; } else { ixh1ap3gi4 = pDataValues [
currTimeIndex + 1 ] ; } } else { real_T f1 = ( t2 - t ) / ( t2 - t1 ) ;
real_T f2 = 1.0 - f1 ; real_T d1 ; real_T d2 ; int_T TimeIndex =
currTimeIndex ; d1 = pDataValues [ TimeIndex ] ; d2 = pDataValues [ TimeIndex
+ 1 ] ; ixh1ap3gi4 = ( real_T ) rtInterpolate ( d1 , d2 , f1 , f2 ) ;
pDataValues += numPoints ; } } } if ( ssIsSampleHit ( rtS , 1 , 0 ) ) { rtB .
gfjl5uvadj = rtDW . a0zxvagfzg ; rtB . kmcjjgcbwm = rtDW . kjcssqsgiy ; }
rtDW . o33bfbbal0 = pyjn4s2eda ; Ireq = muDoubleScalarMin ( muDoubleScalarMax
( ixh1ap3gi4 - j5lp041upu , - rtP . P_ch_max ) , rtP . P_dis_max ) * 1000.0 /
rtP . V_nom ; Q_cur = rtB . gfjl5uvadj * rtB . kmcjjgcbwm ; Q_cur =
muDoubleScalarMin ( muDoubleScalarMax ( ( muDoubleScalarMax ( - Ireq , 0.0 )
- muDoubleScalarMax ( Ireq , 0.0 ) ) + Q_cur , rtP . SOC_min * rtB .
kmcjjgcbwm ) , rtP . SOC_max * rtB . kmcjjgcbwm ) - Q_cur ; if ( Q_cur >= 0.0
) { Ireq = Q_cur ; Q_cur = 0.0 ; } else { Ireq = 0.0 ; Q_cur = - Q_cur ; }
rtB . acbl5n1qaz = rtP . V_nom * Q_cur / 1000.0 * rtP . eta_dis - rtP . V_nom
* Ireq / 1000.0 / rtP . eta_ch ; if ( ssIsSampleHit ( rtS , 3 , 0 ) ) { rtB .
nvs4zgqg5q = rtDW . f3goquxbks ; } if ( ssIsSampleHit ( rtS , 1 , 0 ) ) { rtB
. ljhaxh4oj5 = rtDW . npfta3gsnz ; rtB . c2uoafqle4 = rtDW . bkjs4plmiw ; rtB
. ab2b224ruk = rtDW . lgcqjznrs4 ; rtB . apklv45iea = rtDW . g4elmb3m3d ; rtB
. lkqisxo3wh = rtDW . aihvbm54nh ; rtB . drht0m2wcu = rtDW . pg0uf0tjmq ; rtB
. ktvi0iztpb = rtDW . el3rkvzu35 ; rtB . l1ehz3xtne = rtDW . hgyvxtnudh ; }
rtDW . kxeyldgybk = pyjn4s2eda ; Cdis_i = rtB . ljhaxh4oj5 ; delta_i = rtB .
ab2b224ruk ; Fvirt_prev = rtB . apklv45iea ; seg_dt_dis = rtB . lkqisxo3wh ;
seg_Ah_dis = rtB . drht0m2wcu ; oxbk5ugwgf = rtB . l1ehz3xtne ; xa = ( Q_cur
+ Ireq ) * rtP . Constant1_Value + rtB . ktvi0iztpb ; if ( Q_cur > 0.0 ) {
seg_dt_dis = rtB . lkqisxo3wh + rtP . Constant1_Value ; seg_Ah_dis = Q_cur *
rtP . Constant1_Value + rtB . drht0m2wcu ; } else if ( Ireq > 0.0 ) { delta_i
= rtB . ab2b224ruk + rtP . Constant1_Value ; Fvirt_prev = Ireq * rtP .
Constant1_Value + rtB . apklv45iea ; } if ( rtB . c2uoafqle4 < - 998.0 ) {
rtB . hm2dlit4ls = 0.0 ; rtB . jwrv1jc5tm = rtB . gfjl5uvadj ; rtB .
pamvsakvqt = delta_i ; rtB . ht2kyzk05c = Fvirt_prev ; rtB . anem5cqywe =
seg_dt_dis ; rtB . n35ghbysje = seg_Ah_dis ; rtB . lrgn12tt5s = xa ; rtB .
danczs523w = rtB . l1ehz3xtne ; } else { newdir = muDoubleScalarSign ( rtB .
gfjl5uvadj - rtB . c2uoafqle4 ) ; if ( ( newdir == 0.0 ) || ( newdir == rtB .
ljhaxh4oj5 ) ) { if ( newdir != 0.0 ) { Cdis_i = newdir ; } rtB . hm2dlit4ls
= Cdis_i ; rtB . jwrv1jc5tm = rtB . c2uoafqle4 ; rtB . pamvsakvqt = delta_i ;
rtB . ht2kyzk05c = Fvirt_prev ; rtB . anem5cqywe = seg_dt_dis ; rtB .
n35ghbysje = seg_Ah_dis ; rtB . lrgn12tt5s = xa ; rtB . danczs523w = rtB .
l1ehz3xtne ; } else { oxbk5ugwgf = ( rtB . c2uoafqle4 + rtB . gfjl5uvadj ) *
0.5 ; Cdis_i = 0.0 ; Cch_i = 0.0 ; if ( seg_dt_dis > 0.0 ) { Cdis_i =
seg_Ah_dis / seg_dt_dis / rtP . Q_nom ; } if ( delta_i > 0.0 ) { Cch_i =
Fvirt_prev / delta_i / rtP . Q_nom ; } delta_i = muDoubleScalarExp ( ( ( rtB
. nvs4zgqg5q + 273.15 ) - rtP . Tref_K ) * rtP . kT / ( rtB . nvs4zgqg5q +
273.15 ) ) * rtP . kcyc * muDoubleScalarExp ( muDoubleScalarAbs ( rtB .
gfjl5uvadj - rtB . c2uoafqle4 ) * rtP . kDODc * 100.0 ) * muDoubleScalarExp (
rtP . kCch * Cch_i ) * muDoubleScalarExp ( rtP . kCdch * Cdis_i ) * ( ( 1.0 -
oxbk5ugwgf ) / ( 2.0 * rtP . mSOCref ) * ( rtP . kmSOC * oxbk5ugwgf ) + 1.0 )
; Fvirt_prev = muDoubleScalarPower ( muDoubleScalarMax ( rtB . l1ehz3xtne ,
0.0 ) / muDoubleScalarMax ( delta_i , 2.2204460492503131E-16 ) , 1.0 / rtP .
a_montes ) ; oxbk5ugwgf = muDoubleScalarMax ( ( muDoubleScalarPower ( xa / (
2.0 * rtP . Q_nom ) + Fvirt_prev , rtP . a_montes ) - muDoubleScalarPower (
Fvirt_prev , rtP . a_montes ) ) * delta_i , 0.0 ) + rtB . l1ehz3xtne ; rtB .
hm2dlit4ls = newdir ; rtB . jwrv1jc5tm = rtB . gfjl5uvadj ; rtB . pamvsakvqt
= 0.0 ; rtB . ht2kyzk05c = 0.0 ; rtB . anem5cqywe = 0.0 ; rtB . n35ghbysje =
0.0 ; rtB . lrgn12tt5s = 0.0 ; rtB . danczs523w = oxbk5ugwgf ; } } if (
ssIsSampleHit ( rtS , 2 , 0 ) ) { rtB . gd10qvi0hb = rtDW . o4rhvmic4i ; } if
( ssIsSampleHit ( rtS , 1 , 0 ) ) { rtB . aaksx3pjru = rtDW . bub2n2zpek ;
rtDW . hewzuyypfk = pyjn4s2eda ; xa = muDoubleScalarMax ( 0.0 ,
muDoubleScalarMin ( 1.0 , rtB . gfjl5uvadj ) ) * 0.77992288 + 0.01 ; xa = (
muDoubleScalarExp ( ( rtP . Ua_ref - ( ( ( ( ( muDoubleScalarExp ( - 305.5309
* xa ) * 0.5416 + 0.6379 ) + muDoubleScalarTanh ( - ( xa - 0.1958 ) / 0.1088
) * 0.044 ) - muDoubleScalarTanh ( ( xa - 1.0571 ) / 0.0854 ) * 0.1978 ) -
muDoubleScalarTanh ( ( xa + 0.0117 ) / 0.0529 ) * 0.6875 ) -
muDoubleScalarTanh ( ( xa - 0.5692 ) / 0.0875 ) * 0.0175 ) ) / rtP . Tref_cal
* ( rtP . alpha_cal * rtP . F_const / rtP . R_gas ) ) + rtP . k0_cal ) / (
rtP . k0_cal + 1.0 ) * ( muDoubleScalarExp ( ( 1.0 / ( rtB . nvs4zgqg5q +
273.15 ) - 1.0 / rtP . Tref_cal ) * ( - rtP . Ea_cal / rtP . R_gas ) ) * rtP
. kcal_ref ) * ( muDoubleScalarSqrt ( rtB . gd10qvi0hb + rtP . Constant_Value
) - muDoubleScalarSqrt ( rtB . gd10qvi0hb ) ) * 100.0 + rtB . aaksx3pjru ;
rtB . itatj05zcw = xa ; rtB . aaksx3pjru = xa ; } rtDW . hefs3t3wtj =
pyjn4s2eda ; xa = muDoubleScalarMax ( rtP . SOH_min , 1.0 - ( oxbk5ugwgf +
rtB . itatj05zcw ) / 100.0 ) ; rtB . b5okag1uwe = xa * rtP . Q_nom ; rtB .
kslhz20rry = xa ; rtB . emhm1vcgl4 = Ireq - Q_cur ; rtDW . mpbenfv0mh =
pyjn4s2eda ; Ireq = muDoubleScalarExp ( ( 1.0 / ( rtB . nvs4zgqg5q + 273.15 )
- 0.0033540164346805303 ) * 3000.0 ) * 0.03575 ; Q_cur = muDoubleScalarMax (
0.0 , muDoubleScalarMin ( 1.0 , rtB . gfjl5uvadj ) ) ; low_i = 0 ; do {
exitg1 = 0 ; if ( low_i < 13 ) { if ( muDoubleScalarIsNaN ( c [ low_i ] ) ) {
exitg1 = 1 ; } else { low_i ++ ; } } else { high_i = 13 ; low_i = 0 ; low_ip1
= 2 ; while ( high_i > low_ip1 ) { mid_i = ( ( low_i + high_i ) + 1 ) >> 1 ;
if ( Q_cur >= c [ mid_i - 1 ] ) { low_i = mid_i - 1 ; low_ip1 = mid_i + 1 ; }
else { high_i = mid_i ; } } Q_cur -= c [ low_i ] ; OCV_ref = ( ( Q_cur * b [
low_i ] + b [ low_i + 12 ] ) * Q_cur + b [ low_i + 24 ] ) * Q_cur + b [ low_i
+ 36 ] ; exitg1 = 1 ; } } while ( exitg1 == 0 ) ; rtB . ezqw1dn0pv = ( ( (
rtB . nvs4zgqg5q + 273.15 ) - 298.15 ) * - 0.0003 + OCV_ref ) - rtB .
emhm1vcgl4 * Ireq ; { if ( rtDW . epnl41f4ab . AQHandles [ 0 ] &&
ssGetLogOutput ( rtS ) ) { sdiWriteSignal ( rtDW . epnl41f4ab . AQHandles [ 0
] , ssGetTaskTime ( rtS , 0 ) , ( char * ) & rtB . acbl5n1qaz + 0 ) ;
sdiWriteSignal ( rtDW . epnl41f4ab . AQHandles [ 1 ] , ssGetTaskTime ( rtS ,
0 ) , ( char * ) & rtB . kslhz20rry + 0 ) ; sdiWriteSignal ( rtDW .
epnl41f4ab . AQHandles [ 2 ] , ssGetTaskTime ( rtS , 0 ) , ( char * ) & rtB .
ezqw1dn0pv + 0 ) ; } } if ( ssIsSampleHit ( rtS , 3 , 0 ) ) { rtB .
izewb3fbhm = rtDW . jmly0jp5wg ; } if ( ssIsSampleHit ( rtS , 1 , 0 ) ) { rtB
. llsn45poan = rtB . izewb3fbhm / rtB . kmcjjgcbwm ; } rtB . k3cmfktp1r = ( (
rtB . nvs4zgqg5q + 273.15 ) * rtB . emhm1vcgl4 * - 0.0003 + rtB . emhm1vcgl4
* rtB . emhm1vcgl4 * Ireq ) * rtP . Cth_gain ; UNUSED_PARAMETER ( tid ) ; }
void MdlOutputsTID4 ( int_T tid ) { UNUSED_PARAMETER ( tid ) ; } void
MdlUpdate ( int_T tid ) { if ( ssIsSampleHit ( rtS , 1 , 0 ) ) { rtDW .
a0zxvagfzg = rtB . llsn45poan ; rtDW . kjcssqsgiy = rtB . b5okag1uwe ; rtDW .
npfta3gsnz = rtB . hm2dlit4ls ; rtDW . bkjs4plmiw = rtB . jwrv1jc5tm ; rtDW .
lgcqjznrs4 = rtB . pamvsakvqt ; rtDW . g4elmb3m3d = rtB . ht2kyzk05c ; rtDW .
aihvbm54nh = rtB . anem5cqywe ; rtDW . pg0uf0tjmq = rtB . n35ghbysje ; rtDW .
el3rkvzu35 = rtB . lrgn12tt5s ; rtDW . hgyvxtnudh = rtB . danczs523w ; } if (
ssIsSampleHit ( rtS , 3 , 0 ) ) { rtDW . f3goquxbks += rtP .
DiscreteTimeIntegrator_gainval * rtB . k3cmfktp1r ; } if ( ssIsSampleHit (
rtS , 2 , 0 ) ) { rtDW . o4rhvmic4i += rtP . DiscreteTimeIntegrator1_gainval
* rtP . Constant_Value ; } if ( ssIsSampleHit ( rtS , 1 , 0 ) ) { rtDW .
bub2n2zpek = rtB . aaksx3pjru ; } if ( ssIsSampleHit ( rtS , 3 , 0 ) ) { rtDW
. jmly0jp5wg += rtP . Q_gainval * rtB . emhm1vcgl4 ; if ( rtDW . jmly0jp5wg >
rtP . Q_UpperSat ) { rtDW . jmly0jp5wg = rtP . Q_UpperSat ; } else if ( rtDW
. jmly0jp5wg < rtP . Q_LowerSat ) { rtDW . jmly0jp5wg = rtP . Q_LowerSat ; }
} UNUSED_PARAMETER ( tid ) ; } void MdlUpdateTID4 ( int_T tid ) {
UNUSED_PARAMETER ( tid ) ; } void MdlTerminate ( void ) { rt_FREE ( rtDW .
oquds51bjd . RSimInfoPtr ) ; rt_FREE ( rtDW . l42v1z4ttb . RSimInfoPtr ) ; {
if ( rtDW . epnl41f4ab . AQHandles [ 0 ] ) { sdiTerminateStreaming ( & rtDW .
epnl41f4ab . AQHandles [ 0 ] ) ; } if ( rtDW . epnl41f4ab . AQHandles [ 1 ] )
{ sdiTerminateStreaming ( & rtDW . epnl41f4ab . AQHandles [ 1 ] ) ; } if (
rtDW . epnl41f4ab . AQHandles [ 2 ] ) { sdiTerminateStreaming ( & rtDW .
epnl41f4ab . AQHandles [ 2 ] ) ; } } } static void
mr_battery_sim_cacheDataAsMxArray ( mxArray * destArray , mwIndex i , int j ,
const void * srcData , size_t numBytes ) ; static void
mr_battery_sim_cacheDataAsMxArray ( mxArray * destArray , mwIndex i , int j ,
const void * srcData , size_t numBytes ) { mxArray * newArray =
mxCreateUninitNumericMatrix ( ( size_t ) 1 , numBytes , mxUINT8_CLASS ,
mxREAL ) ; memcpy ( ( uint8_T * ) mxGetData ( newArray ) , ( const uint8_T *
) srcData , numBytes ) ; mxSetFieldByNumber ( destArray , i , j , newArray )
; } static void mr_battery_sim_restoreDataFromMxArray ( void * destData ,
const mxArray * srcArray , mwIndex i , int j , size_t numBytes ) ; static
void mr_battery_sim_restoreDataFromMxArray ( void * destData , const mxArray
* srcArray , mwIndex i , int j , size_t numBytes ) { memcpy ( ( uint8_T * )
destData , ( const uint8_T * ) mxGetData ( mxGetFieldByNumber ( srcArray , i
, j ) ) , numBytes ) ; } static void mr_battery_sim_cacheBitFieldToMxArray (
mxArray * destArray , mwIndex i , int j , uint_T bitVal ) ; static void
mr_battery_sim_cacheBitFieldToMxArray ( mxArray * destArray , mwIndex i , int
j , uint_T bitVal ) { mxSetFieldByNumber ( destArray , i , j ,
mxCreateDoubleScalar ( ( real_T ) bitVal ) ) ; } static uint_T
mr_battery_sim_extractBitFieldFromMxArray ( const mxArray * srcArray ,
mwIndex i , int j , uint_T numBits ) ; static uint_T
mr_battery_sim_extractBitFieldFromMxArray ( const mxArray * srcArray ,
mwIndex i , int j , uint_T numBits ) { const uint_T varVal = ( uint_T )
mxGetScalar ( mxGetFieldByNumber ( srcArray , i , j ) ) ; return varVal & ( (
1u << numBits ) - 1u ) ; } static void
mr_battery_sim_cacheDataToMxArrayWithOffset ( mxArray * destArray , mwIndex i
, int j , mwIndex offset , const void * srcData , size_t numBytes ) ; static
void mr_battery_sim_cacheDataToMxArrayWithOffset ( mxArray * destArray ,
mwIndex i , int j , mwIndex offset , const void * srcData , size_t numBytes )
{ uint8_T * varData = ( uint8_T * ) mxGetData ( mxGetFieldByNumber (
destArray , i , j ) ) ; memcpy ( ( uint8_T * ) & varData [ offset * numBytes
] , ( const uint8_T * ) srcData , numBytes ) ; } static void
mr_battery_sim_restoreDataFromMxArrayWithOffset ( void * destData , const
mxArray * srcArray , mwIndex i , int j , mwIndex offset , size_t numBytes ) ;
static void mr_battery_sim_restoreDataFromMxArrayWithOffset ( void * destData
, const mxArray * srcArray , mwIndex i , int j , mwIndex offset , size_t
numBytes ) { const uint8_T * varData = ( const uint8_T * ) mxGetData (
mxGetFieldByNumber ( srcArray , i , j ) ) ; memcpy ( ( uint8_T * ) destData ,
( const uint8_T * ) & varData [ offset * numBytes ] , numBytes ) ; } static
void mr_battery_sim_cacheBitFieldToCellArrayWithOffset ( mxArray * destArray
, mwIndex i , int j , mwIndex offset , uint_T fieldVal ) ; static void
mr_battery_sim_cacheBitFieldToCellArrayWithOffset ( mxArray * destArray ,
mwIndex i , int j , mwIndex offset , uint_T fieldVal ) { mxSetCell (
mxGetFieldByNumber ( destArray , i , j ) , offset , mxCreateDoubleScalar ( (
real_T ) fieldVal ) ) ; } static uint_T
mr_battery_sim_extractBitFieldFromCellArrayWithOffset ( const mxArray *
srcArray , mwIndex i , int j , mwIndex offset , uint_T numBits ) ; static
uint_T mr_battery_sim_extractBitFieldFromCellArrayWithOffset ( const mxArray
* srcArray , mwIndex i , int j , mwIndex offset , uint_T numBits ) { const
uint_T fieldVal = ( uint_T ) mxGetScalar ( mxGetCell ( mxGetFieldByNumber (
srcArray , i , j ) , offset ) ) ; return fieldVal & ( ( 1u << numBits ) - 1u
) ; } mxArray * mr_battery_sim_GetDWork ( ) { static const char_T *
ssDWFieldNames [ 3 ] = { "rtB" , "rtDW" , "NULL_PrevZCX" , } ; mxArray * ssDW
= mxCreateStructMatrix ( 1 , 1 , 3 , ssDWFieldNames ) ;
mr_battery_sim_cacheDataAsMxArray ( ssDW , 0 , 0 , ( const void * ) & ( rtB )
, sizeof ( rtB ) ) ; { static const char_T * rtdwDataFieldNames [ 26 ] = {
"rtDW.f3goquxbks" , "rtDW.o4rhvmic4i" , "rtDW.jmly0jp5wg" , "rtDW.a0zxvagfzg"
, "rtDW.kjcssqsgiy" , "rtDW.npfta3gsnz" , "rtDW.bkjs4plmiw" ,
"rtDW.lgcqjznrs4" , "rtDW.g4elmb3m3d" , "rtDW.aihvbm54nh" , "rtDW.pg0uf0tjmq"
, "rtDW.el3rkvzu35" , "rtDW.hgyvxtnudh" , "rtDW.bub2n2zpek" ,
"rtDW.o33bfbbal0" , "rtDW.kxeyldgybk" , "rtDW.hefs3t3wtj" , "rtDW.hewzuyypfk"
, "rtDW.mpbenfv0mh" , "rtDW.muknhfqzdo" , "rtDW.dsjkow15mf" ,
"rtDW.feh2m5jwzm" , "rtDW.oo1v0nx2o1" , "rtDW.jouixdcorf" , "rtDW.jsg52rnue1"
, "rtDW.pl5fmt4wih" , } ; mxArray * rtdwData = mxCreateStructMatrix ( 1 , 1 ,
26 , rtdwDataFieldNames ) ; mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0
, 0 , ( const void * ) & ( rtDW . f3goquxbks ) , sizeof ( rtDW . f3goquxbks )
) ; mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 1 , ( const void * ) &
( rtDW . o4rhvmic4i ) , sizeof ( rtDW . o4rhvmic4i ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 2 , ( const void * ) & (
rtDW . jmly0jp5wg ) , sizeof ( rtDW . jmly0jp5wg ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 3 , ( const void * ) & (
rtDW . a0zxvagfzg ) , sizeof ( rtDW . a0zxvagfzg ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 4 , ( const void * ) & (
rtDW . kjcssqsgiy ) , sizeof ( rtDW . kjcssqsgiy ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 5 , ( const void * ) & (
rtDW . npfta3gsnz ) , sizeof ( rtDW . npfta3gsnz ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 6 , ( const void * ) & (
rtDW . bkjs4plmiw ) , sizeof ( rtDW . bkjs4plmiw ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 7 , ( const void * ) & (
rtDW . lgcqjznrs4 ) , sizeof ( rtDW . lgcqjznrs4 ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 8 , ( const void * ) & (
rtDW . g4elmb3m3d ) , sizeof ( rtDW . g4elmb3m3d ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 9 , ( const void * ) & (
rtDW . aihvbm54nh ) , sizeof ( rtDW . aihvbm54nh ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 10 , ( const void * ) & (
rtDW . pg0uf0tjmq ) , sizeof ( rtDW . pg0uf0tjmq ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 11 , ( const void * ) & (
rtDW . el3rkvzu35 ) , sizeof ( rtDW . el3rkvzu35 ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 12 , ( const void * ) & (
rtDW . hgyvxtnudh ) , sizeof ( rtDW . hgyvxtnudh ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 13 , ( const void * ) & (
rtDW . bub2n2zpek ) , sizeof ( rtDW . bub2n2zpek ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 14 , ( const void * ) & (
rtDW . o33bfbbal0 ) , sizeof ( rtDW . o33bfbbal0 ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 15 , ( const void * ) & (
rtDW . kxeyldgybk ) , sizeof ( rtDW . kxeyldgybk ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 16 , ( const void * ) & (
rtDW . hefs3t3wtj ) , sizeof ( rtDW . hefs3t3wtj ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 17 , ( const void * ) & (
rtDW . hewzuyypfk ) , sizeof ( rtDW . hewzuyypfk ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 18 , ( const void * ) & (
rtDW . mpbenfv0mh ) , sizeof ( rtDW . mpbenfv0mh ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 19 , ( const void * ) & (
rtDW . muknhfqzdo ) , sizeof ( rtDW . muknhfqzdo ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 20 , ( const void * ) & (
rtDW . dsjkow15mf ) , sizeof ( rtDW . dsjkow15mf ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 21 , ( const void * ) & (
rtDW . feh2m5jwzm ) , sizeof ( rtDW . feh2m5jwzm ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 22 , ( const void * ) & (
rtDW . oo1v0nx2o1 ) , sizeof ( rtDW . oo1v0nx2o1 ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 23 , ( const void * ) & (
rtDW . jouixdcorf ) , sizeof ( rtDW . jouixdcorf ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 24 , ( const void * ) & (
rtDW . jsg52rnue1 ) , sizeof ( rtDW . jsg52rnue1 ) ) ;
mr_battery_sim_cacheDataAsMxArray ( rtdwData , 0 , 25 , ( const void * ) & (
rtDW . pl5fmt4wih ) , sizeof ( rtDW . pl5fmt4wih ) ) ; mxSetFieldByNumber (
ssDW , 0 , 1 , rtdwData ) ; } return ssDW ; } void mr_battery_sim_SetDWork (
const mxArray * ssDW ) { ( void ) ssDW ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtB ) , ssDW , 0 , 0 ,
sizeof ( rtB ) ) ; { const mxArray * rtdwData = mxGetFieldByNumber ( ssDW , 0
, 1 ) ; mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW .
f3goquxbks ) , rtdwData , 0 , 0 , sizeof ( rtDW . f3goquxbks ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . o4rhvmic4i ) ,
rtdwData , 0 , 1 , sizeof ( rtDW . o4rhvmic4i ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . jmly0jp5wg ) ,
rtdwData , 0 , 2 , sizeof ( rtDW . jmly0jp5wg ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . a0zxvagfzg ) ,
rtdwData , 0 , 3 , sizeof ( rtDW . a0zxvagfzg ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . kjcssqsgiy ) ,
rtdwData , 0 , 4 , sizeof ( rtDW . kjcssqsgiy ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . npfta3gsnz ) ,
rtdwData , 0 , 5 , sizeof ( rtDW . npfta3gsnz ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . bkjs4plmiw ) ,
rtdwData , 0 , 6 , sizeof ( rtDW . bkjs4plmiw ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . lgcqjznrs4 ) ,
rtdwData , 0 , 7 , sizeof ( rtDW . lgcqjznrs4 ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . g4elmb3m3d ) ,
rtdwData , 0 , 8 , sizeof ( rtDW . g4elmb3m3d ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . aihvbm54nh ) ,
rtdwData , 0 , 9 , sizeof ( rtDW . aihvbm54nh ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . pg0uf0tjmq ) ,
rtdwData , 0 , 10 , sizeof ( rtDW . pg0uf0tjmq ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . el3rkvzu35 ) ,
rtdwData , 0 , 11 , sizeof ( rtDW . el3rkvzu35 ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . hgyvxtnudh ) ,
rtdwData , 0 , 12 , sizeof ( rtDW . hgyvxtnudh ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . bub2n2zpek ) ,
rtdwData , 0 , 13 , sizeof ( rtDW . bub2n2zpek ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . o33bfbbal0 ) ,
rtdwData , 0 , 14 , sizeof ( rtDW . o33bfbbal0 ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . kxeyldgybk ) ,
rtdwData , 0 , 15 , sizeof ( rtDW . kxeyldgybk ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . hefs3t3wtj ) ,
rtdwData , 0 , 16 , sizeof ( rtDW . hefs3t3wtj ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . hewzuyypfk ) ,
rtdwData , 0 , 17 , sizeof ( rtDW . hewzuyypfk ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . mpbenfv0mh ) ,
rtdwData , 0 , 18 , sizeof ( rtDW . mpbenfv0mh ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . muknhfqzdo ) ,
rtdwData , 0 , 19 , sizeof ( rtDW . muknhfqzdo ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . dsjkow15mf ) ,
rtdwData , 0 , 20 , sizeof ( rtDW . dsjkow15mf ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . feh2m5jwzm ) ,
rtdwData , 0 , 21 , sizeof ( rtDW . feh2m5jwzm ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . oo1v0nx2o1 ) ,
rtdwData , 0 , 22 , sizeof ( rtDW . oo1v0nx2o1 ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . jouixdcorf ) ,
rtdwData , 0 , 23 , sizeof ( rtDW . jouixdcorf ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . jsg52rnue1 ) ,
rtdwData , 0 , 24 , sizeof ( rtDW . jsg52rnue1 ) ) ;
mr_battery_sim_restoreDataFromMxArray ( ( void * ) & ( rtDW . pl5fmt4wih ) ,
rtdwData , 0 , 25 , sizeof ( rtDW . pl5fmt4wih ) ) ; } } mxArray *
mr_battery_sim_GetSimStateDisallowedBlocks ( ) { return ( NULL ) ; } void
MdlInitializeSizes ( void ) { ssSetNumContStates ( rtS , 0 ) ; ssSetNumY (
rtS , 0 ) ; ssSetNumU ( rtS , 0 ) ; ssSetDirectFeedThrough ( rtS , 0 ) ;
ssSetNumSampleTimes ( rtS , 4 ) ; ssSetNumBlocks ( rtS , 32 ) ;
ssSetNumBlockIO ( rtS , 34 ) ; ssSetNumBlockParams ( rtS , 35088 ) ; } void
MdlInitializeSampleTimes ( void ) { ssSetSampleTime ( rtS , 0 , 0.0 ) ;
ssSetSampleTime ( rtS , 1 , 0.0 ) ; ssSetSampleTime ( rtS , 2 , 1.0 ) ;
ssSetSampleTime ( rtS , 3 , 3600.0 ) ; ssSetOffsetTime ( rtS , 0 , 0.0 ) ;
ssSetOffsetTime ( rtS , 1 , 1.0 ) ; ssSetOffsetTime ( rtS , 2 , 0.0 ) ;
ssSetOffsetTime ( rtS , 3 , 0.0 ) ; } void raccel_set_checksum ( ) {
ssSetChecksumVal ( rtS , 0 , 3438260156U ) ; ssSetChecksumVal ( rtS , 1 ,
1447167630U ) ; ssSetChecksumVal ( rtS , 2 , 1712335604U ) ; ssSetChecksumVal
( rtS , 3 , 163470120U ) ; }
#if defined(_MSC_VER)
#pragma optimize( "", off )
#endif
SimStruct * raccel_register_model ( ssExecutionInfo * executionInfo ) {
static struct _ssMdlInfo mdlInfo ; static struct _ssBlkInfo2 blkInfo2 ;
static struct _ssBlkInfoSLSize blkInfoSLSize ; rt_modelMapInfoPtr = & (
rt_dataMapInfo . mmi ) ; executionInfo -> gblObjects_ . numToFiles = 0 ;
executionInfo -> gblObjects_ . numFrFiles = 0 ; executionInfo -> gblObjects_
. numFrWksBlocks = 2 ; executionInfo -> gblObjects_ . numModelInputs = 0 ;
executionInfo -> gblObjects_ . numRootInportBlks = 0 ; executionInfo ->
gblObjects_ . inportDataTypeIdx = NULL ; executionInfo -> gblObjects_ .
inportDims = NULL ; executionInfo -> gblObjects_ . inportComplex = NULL ;
executionInfo -> gblObjects_ . inportInterpoFlag = NULL ; executionInfo ->
gblObjects_ . inportContinuous = NULL ; ( void ) memset ( ( char_T * ) rtS ,
0 , sizeof ( SimStruct ) ) ; ( void ) memset ( ( char_T * ) & mdlInfo , 0 ,
sizeof ( struct _ssMdlInfo ) ) ; ( void ) memset ( ( char_T * ) & blkInfo2 ,
0 , sizeof ( struct _ssBlkInfo2 ) ) ; ( void ) memset ( ( char_T * ) &
blkInfoSLSize , 0 , sizeof ( struct _ssBlkInfoSLSize ) ) ; ssSetBlkInfo2Ptr (
rtS , & blkInfo2 ) ; ssSetBlkInfoSLSizePtr ( rtS , & blkInfoSLSize ) ;
ssSetMdlInfoPtr ( rtS , & mdlInfo ) ; ssSetExecutionInfo ( rtS ,
executionInfo ) ; slsaAllocOPModelData ( rtS ) ; { static time_T mdlPeriod [
NSAMPLE_TIMES ] ; static time_T mdlOffset [ NSAMPLE_TIMES ] ; static time_T
mdlTaskTimes [ NSAMPLE_TIMES ] ; static int_T mdlTsMap [ NSAMPLE_TIMES ] ;
static int_T mdlSampleHits [ NSAMPLE_TIMES ] ; static boolean_T
mdlTNextWasAdjustedPtr [ NSAMPLE_TIMES ] ; static int_T mdlPerTaskSampleHits
[ NSAMPLE_TIMES * NSAMPLE_TIMES ] ; static time_T mdlTimeOfNextSampleHit [
NSAMPLE_TIMES ] ; { int_T i ; for ( i = 0 ; i < NSAMPLE_TIMES ; i ++ ) {
mdlPeriod [ i ] = 0.0 ; mdlOffset [ i ] = 0.0 ; mdlTaskTimes [ i ] = 0.0 ;
mdlTsMap [ i ] = i ; mdlSampleHits [ i ] = 1 ; } } ssSetSampleTimePtr ( rtS ,
& mdlPeriod [ 0 ] ) ; ssSetOffsetTimePtr ( rtS , & mdlOffset [ 0 ] ) ;
ssSetSampleTimeTaskIDPtr ( rtS , & mdlTsMap [ 0 ] ) ; ssSetTPtr ( rtS , &
mdlTaskTimes [ 0 ] ) ; ssSetSampleHitPtr ( rtS , & mdlSampleHits [ 0 ] ) ;
ssSetTNextWasAdjustedPtr ( rtS , & mdlTNextWasAdjustedPtr [ 0 ] ) ;
ssSetPerTaskSampleHitsPtr ( rtS , & mdlPerTaskSampleHits [ 0 ] ) ;
ssSetTimeOfNextSampleHitPtr ( rtS , & mdlTimeOfNextSampleHit [ 0 ] ) ; }
ssSetSolverMode ( rtS , SOLVER_MODE_SINGLETASKING ) ; { ssSetBlockIO ( rtS ,
( ( void * ) & rtB ) ) ; ( void ) memset ( ( ( void * ) & rtB ) , 0 , sizeof
( B ) ) ; } { void * dwork = ( void * ) & rtDW ; ssSetRootDWork ( rtS , dwork
) ; ( void ) memset ( dwork , 0 , sizeof ( DW ) ) ; } { static
DataTypeTransInfo dtInfo ; ( void ) memset ( ( char_T * ) & dtInfo , 0 ,
sizeof ( dtInfo ) ) ; ssSetModelMappingInfo ( rtS , & dtInfo ) ; dtInfo .
numDataTypes = 25 ; dtInfo . dataTypeSizes = & rtDataTypeSizes [ 0 ] ; dtInfo
. dataTypeNames = & rtDataTypeNames [ 0 ] ; dtInfo . BTransTable = &
rtBTransTable ; dtInfo . PTransTable = & rtPTransTable ; dtInfo .
dataTypeInfoTable = rtDataTypeInfoTable ; } battery_sim_InitializeDataMapInfo
( ) ; ssSetIsRapidAcceleratorActive ( rtS , true ) ; ssSetRootSS ( rtS , rtS
) ; ssSetVersion ( rtS , SIMSTRUCT_VERSION_LEVEL2 ) ; ssSetModelName ( rtS ,
"battery_sim" ) ; ssSetPath ( rtS , "battery_sim" ) ; ssSetTStart ( rtS , 0.0
) ; ssSetTFinal ( rtS , 1000.0 ) ; { static RTWLogInfo rt_DataLoggingInfo ;
rt_DataLoggingInfo . loggingInterval = ( NULL ) ; ssSetRTWLogInfo ( rtS , &
rt_DataLoggingInfo ) ; } { { static int_T rt_LoggedStateWidths [ ] = { 1 , 1
, 1 } ; static int_T rt_LoggedStateNumDimensions [ ] = { 1 , 1 , 1 } ; static
int_T rt_LoggedStateDimensions [ ] = { 1 , 1 , 1 } ; static boolean_T
rt_LoggedStateIsVarDims [ ] = { 0 , 0 , 0 } ; static BuiltInDTypeId
rt_LoggedStateDataTypeIds [ ] = { SS_DOUBLE , SS_DOUBLE , SS_DOUBLE } ;
static int_T rt_LoggedStateComplexSignals [ ] = { 0 , 0 , 0 } ; static
RTWPreprocessingFcnPtr rt_LoggingStatePreprocessingFcnPtrs [ ] = { ( NULL ) ,
( NULL ) , ( NULL ) } ; static const char_T * rt_LoggedStateLabels [ ] = {
"DSTATE" , "DSTATE" , "DSTATE" } ; static const char_T *
rt_LoggedStateBlockNames [ ] = { "battery_sim/Discrete-Time\nIntegrator" ,
"battery_sim/Discrete-Time\nIntegrator1" , "battery_sim/Q" } ; static const
char_T * rt_LoggedStateNames [ ] = { "DSTATE" , "DSTATE" , "DSTATE" } ;
static boolean_T rt_LoggedStateCrossMdlRef [ ] = { 0 , 0 , 0 } ; static
RTWLogDataTypeConvert rt_RTWLogDataTypeConvert [ ] = { { 0 , SS_DOUBLE ,
SS_DOUBLE , 0 , 0 , 0 , 1.0 , 0 , 0.0 } , { 0 , SS_DOUBLE , SS_DOUBLE , 0 , 0
, 0 , 1.0 , 0 , 0.0 } , { 0 , SS_DOUBLE , SS_DOUBLE , 0 , 0 , 0 , 1.0 , 0 ,
0.0 } } ; static int_T rt_LoggedStateIdxList [ ] = { 0 , 1 , 2 } ; static
RTWLogSignalInfo rt_LoggedStateSignalInfo = { 3 , rt_LoggedStateWidths ,
rt_LoggedStateNumDimensions , rt_LoggedStateDimensions ,
rt_LoggedStateIsVarDims , ( NULL ) , ( NULL ) , rt_LoggedStateDataTypeIds ,
rt_LoggedStateComplexSignals , ( NULL ) , rt_LoggingStatePreprocessingFcnPtrs
, { rt_LoggedStateLabels } , ( NULL ) , ( NULL ) , ( NULL ) , {
rt_LoggedStateBlockNames } , { rt_LoggedStateNames } ,
rt_LoggedStateCrossMdlRef , rt_RTWLogDataTypeConvert , rt_LoggedStateIdxList
} ; static void * rt_LoggedStateSignalPtrs [ 3 ] ; rtliSetLogXSignalPtrs (
ssGetRTWLogInfo ( rtS ) , ( LogSignalPtrsType ) rt_LoggedStateSignalPtrs ) ;
rtliSetLogXSignalInfo ( ssGetRTWLogInfo ( rtS ) , & rt_LoggedStateSignalInfo
) ; rt_LoggedStateSignalPtrs [ 0 ] = ( void * ) & rtDW . f3goquxbks ;
rt_LoggedStateSignalPtrs [ 1 ] = ( void * ) & rtDW . o4rhvmic4i ;
rt_LoggedStateSignalPtrs [ 2 ] = ( void * ) & rtDW . jmly0jp5wg ; }
rtliSetLogT ( ssGetRTWLogInfo ( rtS ) , "tout" ) ; rtliSetLogX (
ssGetRTWLogInfo ( rtS ) , "" ) ; rtliSetLogXFinal ( ssGetRTWLogInfo ( rtS ) ,
"xFinal" ) ; rtliSetLogVarNameModifier ( ssGetRTWLogInfo ( rtS ) , "none" ) ;
rtliSetLogFormat ( ssGetRTWLogInfo ( rtS ) , 4 ) ; rtliSetLogMaxRows (
ssGetRTWLogInfo ( rtS ) , 0 ) ; rtliSetLogDecimation ( ssGetRTWLogInfo ( rtS
) , 1 ) ; rtliSetLogY ( ssGetRTWLogInfo ( rtS ) , "" ) ;
rtliSetLogYSignalInfo ( ssGetRTWLogInfo ( rtS ) , ( NULL ) ) ;
rtliSetLogYSignalPtrs ( ssGetRTWLogInfo ( rtS ) , ( NULL ) ) ; } { static
ssSolverInfo slvrInfo ; ssSetStepSize ( rtS , 1.0 ) ; ssSetMinStepSize ( rtS
, 0.0 ) ; ssSetMaxNumMinSteps ( rtS , - 1 ) ; ssSetMinStepViolatedError ( rtS
, 0 ) ; ssSetMaxStepSize ( rtS , 1.0 ) ; ssSetSolverMaxOrder ( rtS , - 1 ) ;
ssSetSolverRefineFactor ( rtS , 1 ) ; ssSetOutputTimes ( rtS , ( NULL ) ) ;
ssSetNumOutputTimes ( rtS , 0 ) ; ssSetOutputTimesOnly ( rtS , 0 ) ;
ssSetOutputTimesIndex ( rtS , 0 ) ; ssSetZCCacheNeedsReset ( rtS , 0 ) ;
ssSetDerivCacheNeedsReset ( rtS , 0 ) ; ssSetNumNonContDerivSigInfos ( rtS ,
0 ) ; ssSetNonContDerivSigInfos ( rtS , ( NULL ) ) ; ssSetSolverInfo ( rtS ,
& slvrInfo ) ; ssSetSolverName ( rtS , "VariableStepDiscrete" ) ;
ssSetVariableStepSolver ( rtS , 1 ) ; ssSetSolverConsistencyChecking ( rtS ,
0 ) ; ssSetSolverAdaptiveZcDetection ( rtS , 0 ) ;
ssSetSolverRobustResetMethod ( rtS , 0 ) ; ssSetSolverStateProjection ( rtS ,
0 ) ; ssSetSolverMassMatrixType ( rtS , ( ssMatrixType ) 0 ) ;
ssSetSolverMassMatrixNzMax ( rtS , 0 ) ; ssSetModelOutputs ( rtS , MdlOutputs
) ; ssSetModelUpdate ( rtS , MdlUpdate ) ; ssSetTNextTid ( rtS , INT_MIN ) ;
ssSetTNext ( rtS , rtMinusInf ) ; ssSetSolverNeedsReset ( rtS ) ;
ssSetNumNonsampledZCs ( rtS , 0 ) ; } ssSetChecksumVal ( rtS , 0 ,
3438260156U ) ; ssSetChecksumVal ( rtS , 1 , 1447167630U ) ; ssSetChecksumVal
( rtS , 2 , 1712335604U ) ; ssSetChecksumVal ( rtS , 3 , 163470120U ) ; {
static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE ; static
RTWExtModeInfo rt_ExtModeInfo ; static const sysRanDType * systemRan [ 6 ] ;
gblRTWExtModeInfo = & rt_ExtModeInfo ; ssSetRTWExtModeInfo ( rtS , &
rt_ExtModeInfo ) ; rteiSetSubSystemActiveVectorAddresses ( & rt_ExtModeInfo ,
systemRan ) ; systemRan [ 0 ] = & rtAlwaysEnabled ; systemRan [ 1 ] = &
rtAlwaysEnabled ; systemRan [ 2 ] = & rtAlwaysEnabled ; systemRan [ 3 ] = &
rtAlwaysEnabled ; systemRan [ 4 ] = & rtAlwaysEnabled ; systemRan [ 5 ] = &
rtAlwaysEnabled ; rteiSetModelMappingInfoPtr ( ssGetRTWExtModeInfo ( rtS ) ,
& ssGetModelMappingInfo ( rtS ) ) ; rteiSetChecksumsPtr ( ssGetRTWExtModeInfo
( rtS ) , ssGetChecksums ( rtS ) ) ; rteiSetTPtr ( ssGetRTWExtModeInfo ( rtS
) , ssGetTPtr ( rtS ) ) ; } slsaDisallowedBlocksForSimTargetOP ( rtS ,
mr_battery_sim_GetSimStateDisallowedBlocks ) ; slsaGetWorkFcnForSimTargetOP (
rtS , mr_battery_sim_GetDWork ) ; slsaSetWorkFcnForSimTargetOP ( rtS ,
mr_battery_sim_SetDWork ) ; rt_RapidReadMatFileAndUpdateParams ( rtS ) ; if (
ssGetErrorStatus ( rtS ) ) { return rtS ; } executionInfo ->
simulationOptions_ . stateSaveName_ = rtliGetLogX ( ssGetRTWLogInfo ( rtS ) )
; executionInfo -> simulationOptions_ . finalStateName_ = rtliGetLogXFinal (
ssGetRTWLogInfo ( rtS ) ) ; executionInfo -> simulationOptions_ .
outputSaveName_ = rtliGetLogY ( ssGetRTWLogInfo ( rtS ) ) ; return rtS ; }
#if defined(_MSC_VER)
#pragma optimize( "", on )
#endif
void MdlOutputsParameterSampleTime ( int_T tid ) { MdlOutputsTID4 ( tid ) ; }
