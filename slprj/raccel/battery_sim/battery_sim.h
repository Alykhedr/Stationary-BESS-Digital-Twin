#ifndef battery_sim_h_
#define battery_sim_h_
#ifndef battery_sim_COMMON_INCLUDES_
#define battery_sim_COMMON_INCLUDES_
#include <stdlib.h>
#include "sl_AsyncioQueue/AsyncioQueueCAPI.h"
#include "rtwtypes.h"
#include "sigstream_rtw.h"
#include "simtarget/slSimTgtSigstreamRTW.h"
#include "simtarget/slSimTgtSlioCoreRTW.h"
#include "simtarget/slSimTgtSlioClientsRTW.h"
#include "simtarget/slSimTgtSlioSdiRTW.h"
#include "simstruc.h"
#include "fixedpoint.h"
#include "raccel.h"
#include "slsv_diagnostic_codegen_c_api.h"
#include "rt_logging_simtarget.h"
#include "rt_nonfinite.h"
#include "math.h"
#include "dt_info.h"
#include "ext_work.h"
#endif
#include "battery_sim_types.h"
#include "mwmathutil.h"
#include <stddef.h>
#include "rtw_modelmap_simtarget.h"
#include "rt_defines.h"
#include <string.h>
#define MODEL_NAME battery_sim
#define NSAMPLE_TIMES (5) 
#define NINPUTS (0)       
#define NOUTPUTS (0)     
#define NBLOCKIO (34) 
#define NUM_ZC_EVENTS (0) 
#ifndef NCSTATES
#define NCSTATES (0)   
#elif NCSTATES != 0
#error Invalid specification of NCSTATES defined in compiler command
#endif
#ifndef rtmGetDataMapInfo
#define rtmGetDataMapInfo(rtm) (*rt_dataMapInfoPtr)
#endif
#ifndef rtmSetDataMapInfo
#define rtmSetDataMapInfo(rtm, val) (rt_dataMapInfoPtr = &val)
#endif
#ifndef IN_RACCEL_MAIN
#endif
typedef struct { real_T gfjl5uvadj ; real_T kmcjjgcbwm ; real_T nvs4zgqg5q ;
real_T ljhaxh4oj5 ; real_T c2uoafqle4 ; real_T ab2b224ruk ; real_T apklv45iea
; real_T lkqisxo3wh ; real_T drht0m2wcu ; real_T ktvi0iztpb ; real_T
l1ehz3xtne ; real_T gd10qvi0hb ; real_T emhm1vcgl4 ; real_T izewb3fbhm ;
real_T llsn45poan ; real_T k3cmfktp1r ; real_T acbl5n1qaz ; real_T hm2dlit4ls
; real_T jwrv1jc5tm ; real_T pamvsakvqt ; real_T ht2kyzk05c ; real_T
anem5cqywe ; real_T n35ghbysje ; real_T lrgn12tt5s ; real_T danczs523w ;
real_T kslhz20rry ; real_T b5okag1uwe ; real_T itatj05zcw ; real_T aaksx3pjru
; real_T ezqw1dn0pv ; } B ; typedef struct { real_T f3goquxbks ; real_T
o4rhvmic4i ; real_T jmly0jp5wg ; real_T a0zxvagfzg ; real_T kjcssqsgiy ;
real_T npfta3gsnz ; real_T bkjs4plmiw ; real_T lgcqjznrs4 ; real_T g4elmb3m3d
; real_T aihvbm54nh ; real_T pg0uf0tjmq ; real_T el3rkvzu35 ; real_T
hgyvxtnudh ; real_T bub2n2zpek ; struct { void * TimePtr ; void * DataPtr ;
void * RSimInfoPtr ; } oquds51bjd ; struct { void * TimePtr ; void * DataPtr
; void * RSimInfoPtr ; } l42v1z4ttb ; struct { void * AQHandles [ 3 ] ; }
epnl41f4ab ; int32_T o33bfbbal0 ; int32_T kxeyldgybk ; int32_T hefs3t3wtj ;
int32_T hewzuyypfk ; int32_T mpbenfv0mh ; struct { int_T PrevIndex ; }
muknhfqzdo ; struct { int_T PrevIndex ; } dsjkow15mf ; boolean_T feh2m5jwzm ;
boolean_T oo1v0nx2o1 ; boolean_T jouixdcorf ; boolean_T jsg52rnue1 ;
boolean_T pl5fmt4wih ; } DW ; typedef struct { rtwCAPI_ModelMappingInfo mmi ;
} DataMapInfo ; struct P_ { real_T Cth_gain ; real_T Ea_cal ; real_T F_const
; real_T P_ch_max ; real_T P_dis_max ; real_T Q_nom ; real_T R_gas ; real_T
SOC_max ; real_T SOC_min ; real_T SOH_min ; real_T Tref_K ; real_T Tref_cal ;
real_T Ua_ref ; real_T V_nom ; real_T a_montes ; real_T alpha_cal ; real_T
eta_ch ; real_T eta_dis ; real_T k0_cal ; real_T kCch ; real_T kCdch ; real_T
kDODc ; real_T kT ; real_T kcal_ref ; real_T kcyc ; real_T kmSOC ; real_T
mSOCref ; real_T FromWorkspace_Time0 [ 8760 ] ; real_T FromWorkspace_Data0 [
8760 ] ; real_T FromWorkspace1_Time0 [ 8760 ] ; real_T FromWorkspace1_Data0 [
8760 ] ; real_T Memory_InitialCondition ; real_T Memory10_InitialCondition ;
real_T DiscreteTimeIntegrator_gainval ; real_T DiscreteTimeIntegrator_IC ;
real_T Memory9_InitialCondition ; real_T Memory8_InitialCondition ; real_T
Memory7_InitialCondition ; real_T Memory6_InitialCondition ; real_T
Memory5_InitialCondition ; real_T Memory4_InitialCondition ; real_T
Memory3_InitialCondition ; real_T Memory2_InitialCondition ; real_T
DiscreteTimeIntegrator1_gainval ; real_T DiscreteTimeIntegrator1_IC ; real_T
Memory1_InitialCondition ; real_T Q_gainval ; real_T Q_IC ; real_T Q_UpperSat
; real_T Q_LowerSat ; real_T Constant_Value ; real_T Constant1_Value ; } ;
extern const char_T * RT_MEMORY_ALLOCATION_ERROR ; extern B rtB ; extern DW
rtDW ; extern P rtP ; extern mxArray * mr_battery_sim_GetDWork ( ) ; extern
void mr_battery_sim_SetDWork ( const mxArray * ssDW ) ; extern mxArray *
mr_battery_sim_GetSimStateDisallowedBlocks ( ) ; extern const
rtwCAPI_ModelMappingStaticInfo * battery_sim_GetCAPIStaticMap ( void ) ;
extern SimStruct * const rtS ; extern DataMapInfo * rt_dataMapInfoPtr ;
extern rtwCAPI_ModelMappingInfo * rt_modelMapInfoPtr ; void MdlOutputs (
int_T tid ) ; void MdlOutputsParameterSampleTime ( int_T tid ) ; void
MdlUpdate ( int_T tid ) ; void MdlTerminate ( void ) ; void
MdlInitializeSizes ( void ) ; void MdlInitializeSampleTimes ( void ) ;
SimStruct * raccel_register_model ( ssExecutionInfo * executionInfo ) ;
#endif
