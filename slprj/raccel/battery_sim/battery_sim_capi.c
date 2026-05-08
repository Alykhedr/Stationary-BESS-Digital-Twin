#include "rtw_capi.h"
#ifdef HOST_CAPI_BUILD
#include "battery_sim_capi_host.h"
#define sizeof(s) ((size_t)(0xFFFF))
#undef rt_offsetof
#define rt_offsetof(s,el) ((uint16_T)(0xFFFF))
#define TARGET_CONST
#define TARGET_STRING(s) (s)
#ifndef SS_UINT64
#define SS_UINT64 19
#endif
#ifndef SS_INT64
#define SS_INT64 20
#endif
#else
#include "builtin_typeid_types.h"
#include "battery_sim.h"
#include "battery_sim_capi.h"
#include "battery_sim_private.h"
#ifdef LIGHT_WEIGHT_CAPI
#define TARGET_CONST
#define TARGET_STRING(s)               ((NULL))
#else
#define TARGET_CONST                   const
#define TARGET_STRING(s)               (s)
#endif
#endif
static const rtwCAPI_Signals rtBlockSignals [ ] = { { 0 , 1 , TARGET_STRING (
"battery_sim/MATLAB Function" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 0 }
, { 1 , 2 , TARGET_STRING ( "battery_sim/MATLAB Function1" ) , TARGET_STRING
( "" ) , 0 , 0 , 0 , 0 , 1 } , { 2 , 2 , TARGET_STRING (
"battery_sim/MATLAB Function1" ) , TARGET_STRING ( "" ) , 1 , 0 , 0 , 0 , 1 }
, { 3 , 3 , TARGET_STRING ( "battery_sim/MATLAB Function2" ) , TARGET_STRING
( "" ) , 0 , 0 , 0 , 0 , 0 } , { 4 , 3 , TARGET_STRING (
"battery_sim/MATLAB Function2" ) , TARGET_STRING ( "Ca" ) , 1 , 0 , 0 , 0 , 0
} , { 5 , 4 , TARGET_STRING ( "battery_sim/MATLAB Function3" ) ,
TARGET_STRING ( "" ) , 1 , 0 , 0 , 0 , 0 } , { 6 , 4 , TARGET_STRING (
"battery_sim/MATLAB Function3" ) , TARGET_STRING ( "" ) , 2 , 0 , 0 , 0 , 0 }
, { 7 , 4 , TARGET_STRING ( "battery_sim/MATLAB Function3" ) , TARGET_STRING
( "" ) , 3 , 0 , 0 , 0 , 0 } , { 8 , 4 , TARGET_STRING (
"battery_sim/MATLAB Function3" ) , TARGET_STRING ( "" ) , 4 , 0 , 0 , 0 , 0 }
, { 9 , 4 , TARGET_STRING ( "battery_sim/MATLAB Function3" ) , TARGET_STRING
( "" ) , 5 , 0 , 0 , 0 , 0 } , { 10 , 4 , TARGET_STRING (
"battery_sim/MATLAB Function3" ) , TARGET_STRING ( "" ) , 6 , 0 , 0 , 0 , 0 }
, { 11 , 4 , TARGET_STRING ( "battery_sim/MATLAB Function3" ) , TARGET_STRING
( "" ) , 7 , 0 , 0 , 0 , 0 } , { 12 , 4 , TARGET_STRING (
"battery_sim/MATLAB Function3" ) , TARGET_STRING ( "" ) , 8 , 0 , 0 , 0 , 0 }
, { 13 , 5 , TARGET_STRING ( "battery_sim/MATLAB Function5" ) , TARGET_STRING
( "" ) , 2 , 0 , 0 , 0 , 0 } , { 14 , 0 , TARGET_STRING (
"battery_sim/Discrete-Time Integrator" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 ,
0 , 2 } , { 15 , 0 , TARGET_STRING ( "battery_sim/Discrete-Time Integrator1"
) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 3 } , { 16 , 0 , TARGET_STRING (
"battery_sim/Q" ) , TARGET_STRING ( "Q" ) , 0 , 0 , 0 , 0 , 2 } , { 17 , 0 ,
TARGET_STRING ( "battery_sim/Gain" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 ,
0 } , { 18 , 0 , TARGET_STRING ( "battery_sim/Memory" ) , TARGET_STRING ( ""
) , 0 , 0 , 0 , 0 , 1 } , { 19 , 0 , TARGET_STRING ( "battery_sim/Memory10" )
, TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 1 } , { 20 , 0 , TARGET_STRING (
"battery_sim/Memory2" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 1 } , { 21 ,
0 , TARGET_STRING ( "battery_sim/Memory3" ) , TARGET_STRING ( "" ) , 0 , 0 ,
0 , 0 , 1 } , { 22 , 0 , TARGET_STRING ( "battery_sim/Memory4" ) ,
TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 1 } , { 23 , 0 , TARGET_STRING (
"battery_sim/Memory5" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 1 } , { 24 ,
0 , TARGET_STRING ( "battery_sim/Memory6" ) , TARGET_STRING ( "" ) , 0 , 0 ,
0 , 0 , 1 } , { 25 , 0 , TARGET_STRING ( "battery_sim/Memory7" ) ,
TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 1 } , { 26 , 0 , TARGET_STRING (
"battery_sim/Memory8" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 1 } , { 27 ,
0 , TARGET_STRING ( "battery_sim/Memory9" ) , TARGET_STRING ( "" ) , 0 , 0 ,
0 , 0 , 1 } , { 28 , 0 , TARGET_STRING ( "battery_sim/Divide" ) ,
TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 1 } , { 29 , 0 , TARGET_STRING (
"battery_sim/Sum" ) , TARGET_STRING ( "" ) , 0 , 0 , 0 , 0 , 0 } , { 0 , 0 ,
( NULL ) , ( NULL ) , 0 , 0 , 0 , 0 , 0 } } ; static const
rtwCAPI_BlockParameters rtBlockParameters [ ] = { { 30 , TARGET_STRING (
"battery_sim/Constant" ) , TARGET_STRING ( "Value" ) , 0 , 0 , 0 } , { 31 ,
TARGET_STRING ( "battery_sim/Constant1" ) , TARGET_STRING ( "Value" ) , 0 , 0
, 0 } , { 32 , TARGET_STRING ( "battery_sim/Discrete-Time Integrator" ) ,
TARGET_STRING ( "gainval" ) , 0 , 0 , 0 } , { 33 , TARGET_STRING (
"battery_sim/Discrete-Time Integrator" ) , TARGET_STRING ( "InitialCondition"
) , 0 , 0 , 0 } , { 34 , TARGET_STRING (
"battery_sim/Discrete-Time Integrator1" ) , TARGET_STRING ( "gainval" ) , 0 ,
0 , 0 } , { 35 , TARGET_STRING ( "battery_sim/Discrete-Time Integrator1" ) ,
TARGET_STRING ( "InitialCondition" ) , 0 , 0 , 0 } , { 36 , TARGET_STRING (
"battery_sim/Q" ) , TARGET_STRING ( "gainval" ) , 0 , 0 , 0 } , { 37 ,
TARGET_STRING ( "battery_sim/Q" ) , TARGET_STRING ( "InitialCondition" ) , 0
, 0 , 0 } , { 38 , TARGET_STRING ( "battery_sim/Q" ) , TARGET_STRING (
"UpperSaturationLimit" ) , 0 , 0 , 0 } , { 39 , TARGET_STRING (
"battery_sim/Q" ) , TARGET_STRING ( "LowerSaturationLimit" ) , 0 , 0 , 0 } ,
{ 40 , TARGET_STRING ( "battery_sim/From Workspace" ) , TARGET_STRING (
"Time0" ) , 0 , 1 , 0 } , { 41 , TARGET_STRING ( "battery_sim/From Workspace"
) , TARGET_STRING ( "Data0" ) , 0 , 1 , 0 } , { 42 , TARGET_STRING (
"battery_sim/From Workspace1" ) , TARGET_STRING ( "Time0" ) , 0 , 1 , 0 } , {
43 , TARGET_STRING ( "battery_sim/From Workspace1" ) , TARGET_STRING (
"Data0" ) , 0 , 1 , 0 } , { 44 , TARGET_STRING ( "battery_sim/Memory" ) ,
TARGET_STRING ( "InitialCondition" ) , 0 , 0 , 0 } , { 45 , TARGET_STRING (
"battery_sim/Memory1" ) , TARGET_STRING ( "InitialCondition" ) , 0 , 0 , 0 }
, { 46 , TARGET_STRING ( "battery_sim/Memory10" ) , TARGET_STRING (
"InitialCondition" ) , 0 , 0 , 0 } , { 47 , TARGET_STRING (
"battery_sim/Memory2" ) , TARGET_STRING ( "InitialCondition" ) , 0 , 0 , 0 }
, { 48 , TARGET_STRING ( "battery_sim/Memory3" ) , TARGET_STRING (
"InitialCondition" ) , 0 , 0 , 0 } , { 49 , TARGET_STRING (
"battery_sim/Memory4" ) , TARGET_STRING ( "InitialCondition" ) , 0 , 0 , 0 }
, { 50 , TARGET_STRING ( "battery_sim/Memory5" ) , TARGET_STRING (
"InitialCondition" ) , 0 , 0 , 0 } , { 51 , TARGET_STRING (
"battery_sim/Memory6" ) , TARGET_STRING ( "InitialCondition" ) , 0 , 0 , 0 }
, { 52 , TARGET_STRING ( "battery_sim/Memory7" ) , TARGET_STRING (
"InitialCondition" ) , 0 , 0 , 0 } , { 53 , TARGET_STRING (
"battery_sim/Memory8" ) , TARGET_STRING ( "InitialCondition" ) , 0 , 0 , 0 }
, { 54 , TARGET_STRING ( "battery_sim/Memory9" ) , TARGET_STRING (
"InitialCondition" ) , 0 , 0 , 0 } , { 0 , ( NULL ) , ( NULL ) , 0 , 0 , 0 }
} ; static int_T rt_LoggedStateIdxList [ ] = { - 1 } ; static const
rtwCAPI_Signals rtRootInputs [ ] = { { 0 , 0 , ( NULL ) , ( NULL ) , 0 , 0 ,
0 , 0 , 0 } } ; static const rtwCAPI_Signals rtRootOutputs [ ] = { { 0 , 0 ,
( NULL ) , ( NULL ) , 0 , 0 , 0 , 0 , 0 } } ; static const
rtwCAPI_ModelParameters rtModelParameters [ ] = { { 55 , TARGET_STRING (
"Cth_gain" ) , 0 , 0 , 0 } , { 56 , TARGET_STRING ( "Ea_cal" ) , 0 , 0 , 0 }
, { 57 , TARGET_STRING ( "F_const" ) , 0 , 0 , 0 } , { 58 , TARGET_STRING (
"P_ch_max" ) , 0 , 0 , 0 } , { 59 , TARGET_STRING ( "P_dis_max" ) , 0 , 0 , 0
} , { 60 , TARGET_STRING ( "Q_nom" ) , 0 , 0 , 0 } , { 61 , TARGET_STRING (
"R_gas" ) , 0 , 0 , 0 } , { 62 , TARGET_STRING ( "SOC_max" ) , 0 , 0 , 0 } ,
{ 63 , TARGET_STRING ( "SOC_min" ) , 0 , 0 , 0 } , { 64 , TARGET_STRING (
"SOH_min" ) , 0 , 0 , 0 } , { 65 , TARGET_STRING ( "Tref_K" ) , 0 , 0 , 0 } ,
{ 66 , TARGET_STRING ( "Tref_cal" ) , 0 , 0 , 0 } , { 67 , TARGET_STRING (
"Ua_ref" ) , 0 , 0 , 0 } , { 68 , TARGET_STRING ( "V_nom" ) , 0 , 0 , 0 } , {
69 , TARGET_STRING ( "a_montes" ) , 0 , 0 , 0 } , { 70 , TARGET_STRING (
"alpha_cal" ) , 0 , 0 , 0 } , { 71 , TARGET_STRING ( "eta_ch" ) , 0 , 0 , 0 }
, { 72 , TARGET_STRING ( "eta_dis" ) , 0 , 0 , 0 } , { 73 , TARGET_STRING (
"k0_cal" ) , 0 , 0 , 0 } , { 74 , TARGET_STRING ( "kCch" ) , 0 , 0 , 0 } , {
75 , TARGET_STRING ( "kCdch" ) , 0 , 0 , 0 } , { 76 , TARGET_STRING ( "kDODc"
) , 0 , 0 , 0 } , { 77 , TARGET_STRING ( "kT" ) , 0 , 0 , 0 } , { 78 ,
TARGET_STRING ( "kcal_ref" ) , 0 , 0 , 0 } , { 79 , TARGET_STRING ( "kcyc" )
, 0 , 0 , 0 } , { 80 , TARGET_STRING ( "kmSOC" ) , 0 , 0 , 0 } , { 81 ,
TARGET_STRING ( "mSOCref" ) , 0 , 0 , 0 } , { 0 , ( NULL ) , 0 , 0 , 0 } } ;
#ifndef HOST_CAPI_BUILD
static void * rtDataAddrMap [ ] = { & rtB . ezqw1dn0pv , & rtB . itatj05zcw ,
& rtB . aaksx3pjru , & rtB . kslhz20rry , & rtB . b5okag1uwe , & rtB .
hm2dlit4ls , & rtB . jwrv1jc5tm , & rtB . pamvsakvqt , & rtB . ht2kyzk05c , &
rtB . anem5cqywe , & rtB . n35ghbysje , & rtB . lrgn12tt5s , & rtB .
danczs523w , & rtB . acbl5n1qaz , & rtB . nvs4zgqg5q , & rtB . gd10qvi0hb , &
rtB . izewb3fbhm , & rtB . k3cmfktp1r , & rtB . gfjl5uvadj , & rtB .
kmcjjgcbwm , & rtB . l1ehz3xtne , & rtB . ktvi0iztpb , & rtB . drht0m2wcu , &
rtB . lkqisxo3wh , & rtB . apklv45iea , & rtB . ab2b224ruk , & rtB .
c2uoafqle4 , & rtB . ljhaxh4oj5 , & rtB . llsn45poan , & rtB . emhm1vcgl4 , &
rtP . Constant_Value , & rtP . Constant1_Value , & rtP .
DiscreteTimeIntegrator_gainval , & rtP . DiscreteTimeIntegrator_IC , & rtP .
DiscreteTimeIntegrator1_gainval , & rtP . DiscreteTimeIntegrator1_IC , & rtP
. Q_gainval , & rtP . Q_IC , & rtP . Q_UpperSat , & rtP . Q_LowerSat , & rtP
. FromWorkspace_Time0 [ 0 ] , & rtP . FromWorkspace_Data0 [ 0 ] , & rtP .
FromWorkspace1_Time0 [ 0 ] , & rtP . FromWorkspace1_Data0 [ 0 ] , & rtP .
Memory_InitialCondition , & rtP . Memory1_InitialCondition , & rtP .
Memory10_InitialCondition , & rtP . Memory2_InitialCondition , & rtP .
Memory3_InitialCondition , & rtP . Memory4_InitialCondition , & rtP .
Memory5_InitialCondition , & rtP . Memory6_InitialCondition , & rtP .
Memory7_InitialCondition , & rtP . Memory8_InitialCondition , & rtP .
Memory9_InitialCondition , & rtP . Cth_gain , & rtP . Ea_cal , & rtP .
F_const , & rtP . P_ch_max , & rtP . P_dis_max , & rtP . Q_nom , & rtP .
R_gas , & rtP . SOC_max , & rtP . SOC_min , & rtP . SOH_min , & rtP . Tref_K
, & rtP . Tref_cal , & rtP . Ua_ref , & rtP . V_nom , & rtP . a_montes , &
rtP . alpha_cal , & rtP . eta_ch , & rtP . eta_dis , & rtP . k0_cal , & rtP .
kCch , & rtP . kCdch , & rtP . kDODc , & rtP . kT , & rtP . kcal_ref , & rtP
. kcyc , & rtP . kmSOC , & rtP . mSOCref , } ; static int32_T *
rtVarDimsAddrMap [ ] = { ( NULL ) } ;
#endif
static TARGET_CONST rtwCAPI_DataTypeMap rtDataTypeMap [ ] = { { "double" ,
"real_T" , 0 , 0 , sizeof ( real_T ) , ( uint8_T ) SS_DOUBLE , 0 , 0 , 0 } }
;
#ifdef HOST_CAPI_BUILD
#undef sizeof
#endif
static TARGET_CONST rtwCAPI_ElementMap rtElementMap [ ] = { { ( NULL ) , 0 ,
0 , 0 , 0 } , } ; static const rtwCAPI_DimensionMap rtDimensionMap [ ] = { {
rtwCAPI_SCALAR , 0 , 2 , 0 } , { rtwCAPI_VECTOR , 2 , 2 , 0 } } ; static
const uint_T rtDimensionArray [ ] = { 1 , 1 , 8760 , 1 } ; static const
real_T rtcapiStoredFloats [ ] = { 0.0 , 1.0 , 3600.0 } ; static const
rtwCAPI_FixPtMap rtFixPtMap [ ] = { { ( NULL ) , ( NULL ) ,
rtwCAPI_FIX_RESERVED , 0 , 0 , ( boolean_T ) 0 } , } ; static const
rtwCAPI_SampleTimeMap rtSampleTimeMap [ ] = { { ( const void * ) &
rtcapiStoredFloats [ 0 ] , ( const void * ) & rtcapiStoredFloats [ 0 ] , (
int8_T ) 0 , ( uint8_T ) 0 } , { ( const void * ) & rtcapiStoredFloats [ 0 ]
, ( const void * ) & rtcapiStoredFloats [ 1 ] , ( int8_T ) 1 , ( uint8_T ) 0
} , { ( const void * ) & rtcapiStoredFloats [ 2 ] , ( const void * ) &
rtcapiStoredFloats [ 0 ] , ( int8_T ) 3 , ( uint8_T ) 0 } , { ( const void *
) & rtcapiStoredFloats [ 1 ] , ( const void * ) & rtcapiStoredFloats [ 0 ] ,
( int8_T ) 2 , ( uint8_T ) 0 } } ; static rtwCAPI_ModelMappingStaticInfo
mmiStatic = { { rtBlockSignals , 30 , rtRootInputs , 0 , rtRootOutputs , 0 }
, { rtBlockParameters , 25 , rtModelParameters , 27 } , { ( NULL ) , 0 } , {
rtDataTypeMap , rtDimensionMap , rtFixPtMap , rtElementMap , rtSampleTimeMap
, rtDimensionArray } , "float" , { 3438260156U , 1447167630U , 1712335604U ,
163470120U } , ( NULL ) , 0 , ( boolean_T ) 0 , rt_LoggedStateIdxList } ;
const rtwCAPI_ModelMappingStaticInfo * battery_sim_GetCAPIStaticMap ( void )
{ return & mmiStatic ; }
#ifndef HOST_CAPI_BUILD
void battery_sim_InitializeDataMapInfo ( void ) { rtwCAPI_SetVersion ( ( *
rt_dataMapInfoPtr ) . mmi , 1 ) ; rtwCAPI_SetStaticMap ( ( *
rt_dataMapInfoPtr ) . mmi , & mmiStatic ) ; rtwCAPI_SetLoggingStaticMap ( ( *
rt_dataMapInfoPtr ) . mmi , ( NULL ) ) ; rtwCAPI_SetDataAddressMap ( ( *
rt_dataMapInfoPtr ) . mmi , rtDataAddrMap ) ; rtwCAPI_SetVarDimsAddressMap (
( * rt_dataMapInfoPtr ) . mmi , rtVarDimsAddrMap ) ;
rtwCAPI_SetInstanceLoggingInfo ( ( * rt_dataMapInfoPtr ) . mmi , ( NULL ) ) ;
rtwCAPI_SetChildMMIArray ( ( * rt_dataMapInfoPtr ) . mmi , ( NULL ) ) ;
rtwCAPI_SetChildMMIArrayLen ( ( * rt_dataMapInfoPtr ) . mmi , 0 ) ; }
#else
#ifdef __cplusplus
extern "C" {
#endif
void battery_sim_host_InitializeDataMapInfo ( battery_sim_host_DataMapInfo_T
* dataMap , const char * path ) { rtwCAPI_SetVersion ( dataMap -> mmi , 1 ) ;
rtwCAPI_SetStaticMap ( dataMap -> mmi , & mmiStatic ) ;
rtwCAPI_SetDataAddressMap ( dataMap -> mmi , ( NULL ) ) ;
rtwCAPI_SetVarDimsAddressMap ( dataMap -> mmi , ( NULL ) ) ; rtwCAPI_SetPath
( dataMap -> mmi , path ) ; rtwCAPI_SetFullPath ( dataMap -> mmi , ( NULL ) )
; rtwCAPI_SetChildMMIArray ( dataMap -> mmi , ( NULL ) ) ;
rtwCAPI_SetChildMMIArrayLen ( dataMap -> mmi , 0 ) ; }
#ifdef __cplusplus
}
#endif
#endif
