//===========================================================================
//  File Name: r12c.c
//
//  Copyright 2015 Magnum Semiconductor Inc.  All rights reserved.
//
//  Description:
//      Entry function of R12CPU
//
//===========================================================================
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

//#include "OSWrapper.h"

#include <errno.h>
#include <assert.h>


#include "bsp_sharedmem.h"
#include <unistd.h>
#include "osal_common.h"
#include "osal_io.h"
#include "osal_shareMem.h"
#include "osal_semNamed.h"

#include "cwBspApi.h"
#include "r12c.h"
#include <sys/resource.h>
#include <sys/types.h>
#include <signal.h>
#include "osw_taskLib.h"

#include <cpuid.h>

/**********************************************************************
 * Definitions
 ***********************************************************************/
#define MAX_CONFIG_INDEX    (5)
#define DEFAULT_VD7_NAME    "VD7"

/**********************************************************************
 * GLOBAL VAR
 ***********************************************************************/
strR12CParam gR12CParam;

extern FILE *gVuartInput;
extern FILE *gVuartOutput;
extern unsigned long gShmBaseAddr;

/***********************************************************************
 *
 *  void r12c_usage(void)
 *
 *  Function:
 *
 *  Show the usage of this App.
 *
 *  Returns:
 *
 *
 ***********************************************************************/

void r12c_usage(void)
{
    printf("r12c Version 0.1\n");

    printf("Usage: \n");
    printf("r12c -c <instance> -n <name> \n");

    printf("\tparameter: \n");

    printf("\t\t-c <instance> is a number that uniquely identifies a VD7\n");
    printf("\t\t-n <name> is a string that is descriptive of the VD7\n");


    printf("\texample:\n");
    printf("\t./r12c -c 0\n");

    return;
}


/***********************************************************************
 *
 *  void sigxfsz_handler(void)
 *
 *  Function:
 *
 *  Handler of SIGXFSZ.
 *
 *  Returns:
 *
 *
 ***********************************************************************/

void sigxfsz_handler(int signo, siginfo_t *info, void *context)
{
    struct rlimit rlim;
    off_t offset = 0;

    getrlimit(RLIMIT_FSIZE, &rlim);
    offset = lseek(STDOUT_FILENO, 0, SEEK_CUR);
    if(offset > (rlim.rlim_cur / 2))
    {
        lseek(STDOUT_FILENO, 0, SEEK_SET);
    }
}

/***********************************************************************
 *
 *  const char* cpuid_get_vendor(void)
 *
 *  Function:
 *
 *  Reads vendor (example "GenuineIntel") from cpuid information.
 *
 *  Returns:
 *
 *  Vendor string.
 *
 ***********************************************************************/

static const char* cpuid_get_vendor(void)
{
  unsigned int eax, ebx, ecx, edx;
  static char vendor[13];

  // check that cpuid is supported
  if (!__get_cpuid_max(0, NULL)) return "";

  // get leaf 0
  __cpuid(0, eax, ebx, ecx, edx);
  // concatenate vendor string
  *(unsigned int*)&vendor[0] = ebx;
  *(unsigned int*)&vendor[4] = edx;
  *(unsigned int*)&vendor[8] = ecx;
  // nul-terminate
  vendor[12] = '\0';

  return vendor;
}

/***********************************************************************
 *
 *  const char* cpuid_get_model(void)
 *
 *  Function:
 *
 *  Reads model (example "Intel(R) Xeon(R) CPU E5-2697 v3 @ 2.60GHz")
 *  from cpuid information.
 *
 *  Returns:
 *
 *  Model string.
 *
 ***********************************************************************/

static const char* cpuid_get_model(void)
{
  unsigned int eax, ebx, ecx, edx;
  static char model[49];

  // check that leaf 0x80000002-4 is supported
  if (__get_cpuid_max(0x80000000, NULL) < 0x80000004) return "";

  // get leaf 0x80000002
  __cpuid(0x80000002, eax, ebx, ecx, edx);
  // concatenate model string
  *(unsigned int*)&model[0] = eax;
  *(unsigned int*)&model[4] = ebx;
  *(unsigned int*)&model[8] = ecx;
  *(unsigned int*)&model[12] = edx;
  // get leaf 0x80000003
  __cpuid(0x80000003, eax, ebx, ecx, edx);
  // concatenate brand string
  *(unsigned int*)&model[16] = eax;
  *(unsigned int*)&model[20] = ebx;
  *(unsigned int*)&model[24] = ecx;
  *(unsigned int*)&model[28] = edx;
  // get leaf 0x80000004
  __cpuid(0x80000004, eax, ebx, ecx, edx);
  // concatenate brand string
  *(unsigned int*)&model[32] = eax;
  *(unsigned int*)&model[36] = ebx;
  *(unsigned int*)&model[40] = ecx;
  *(unsigned int*)&model[44] = edx;
  // nul-terminate
  model[48] = '\0';

  return model;
}

/***********************************************************************
 *
 *  unsigned int cpuid_has_avx(void)
 *
 *  Function:
 *
 *  Checks cpuid information for AVX instruction set extension support.
 *
 *  Returns:
 *
 *  Zero if AVX not supported, non-zero if AVX supported.
 *
 ***********************************************************************/

static unsigned int cpuid_has_avx(void)
{
  unsigned int eax, ebx, ecx, edx;

  // check that leaf 1 is supported
  if (__get_cpuid_max(0, NULL) < 1) return 0;

  // get cpuid leaf 1
  __cpuid(1, eax, ebx, ecx, edx);
  // check AVX bit
  return ecx & bit_AVX;
}

/***********************************************************************
 *
 *  unsigned int cpuid_has_avx2(void)
 *
 *  Function:
 *
 *  Checks cpuid information for AVX2 instruction set extension support.
 *
 *  Returns:
 *
 *  Zero if AVX2 not supported, non-zero if AVX2 supported.
 *
 ***********************************************************************/

static unsigned int cpuid_has_avx2(void)
{
  unsigned int eax, ebx, ecx, edx;

  // check that leaf 7 is supported
  if (__get_cpuid_max(0, NULL) < 7) return 0;

  // get cpuid leaf 7 subleaf 0, if it is supported
  __cpuid_count(7, 0, eax, ebx, ecx, edx);
  // check AVX2 bit
  return ebx & bit_AVX2;
}

/***********************************************************************
 *
 *  unsigned int cpuid_has_abm(void)
 *
 *  Function:
 *
 *  Checks cpuid information for ABM (Advanced Bit Manipulation)
 *  instruction set extension support.
 *
 *  Returns:
 *
 *  Zero if ABM not supported, non-zero if ABM supported.
 *
 ***********************************************************************/

static unsigned int cpuid_has_abm(void)
{
  unsigned int eax, ebx, ecx, edx;

  // check that leaf 0x80000001 is supported
  if (__get_cpuid_max(0x80000000, NULL) < 0x80000001) return 0;

  // get cpuid leaf 0x80000001
  __cpuid(0x80000001, eax, ebx, ecx, edx);
  // check ABM bit
  return ecx & bit_ABM;
}

/***********************************************************************
 *
 *  unsigned int cpuid_has_bmi(void)
 *
 *  Function:
 *
 *  Checks cpuid information for BMI (Bit Manipulation Instructions)
 *  instruction set extension support.
 *
 *  Returns:
 *
 *  Zero if BMI not supported, non-zero if BMI supported.
 *
 ***********************************************************************/

static unsigned int cpuid_has_bmi(void)
{
  unsigned int eax, ebx, ecx, edx;

  // check that leaf 7 is supported
  if (__get_cpuid_max(0, NULL) < 7) return 0;

  // get cpuid leaf 7 subleaf 0, if it is supported
  __cpuid_count(7, 0, eax, ebx, ecx, edx);
  // check BMI bit
  return ebx & bit_BMI;
}

/***********************************************************************
 *
 *  unsigned int cpuid_has_bmi2(void)
 *
 *  Function:
 *
 *  Checks cpuid information for BMI2 (Bit Manipulation Instructions 2)
 *  instruction set extension support.
 *
 *  Returns:
 *
 *  Zero if BMI2 not supported, non-zero if BMI2 supported.
 *
 ***********************************************************************/

static unsigned int cpuid_has_bmi2(void)
{
  unsigned int eax, ebx, ecx, edx;

  // check that leaf 7 is supported
  if (__get_cpuid_max(0, NULL) < 7) return 0;

  // get cpuid leaf 7 subleaf 0, if it is supported
  __cpuid_count(7, 0, eax, ebx, ecx, edx);
  // check BMI2 bit
  return ebx & bit_BMI2;
}


/***********************************************************************
 *
 *  int get_arguments(int argc, char **argv, strR12CParam* r12CParam)
 *
 *  Function:
 *
 *  Get augument.
 *
 *  Returns:
 *
 *
 *
 *
 ***********************************************************************/
 #if 0
static int get_arguments(int argc, char **argv, strR12CParam* r12CParam)
{
    int c;
    int ret = TRUE;
    char* const short_options = "hc:n:p:";

    struct option long_options[] = {
         { "help",        0,    NULL,    'h'     },
         { "instance",    1,    NULL,    'c'     },
         { "name",        1,    NULL,    'n'     },
         {  NULL,         0,    NULL,    0       }
    };


    // set default
    memset(r12CParam, 0, sizeof(strR12CParam));
    r12CParam->instance = -1;

    // get arguments
    while((c = getopt_long_only (argc, argv, short_options, long_options, NULL)) != -1)
    {
        switch (c)
        {
            case 'c':
            {
                r12CParam->instance = atoi(optarg);
                break;
            }
            case 'n':
            {
                // We may need a default name if no name is passed
                strcpy(r12CParam->name, optarg);
                break;
            }
            case 'h':
            default:
                r12c_usage();
                exit(0);
        }
    }

    //Validation check on instance number
    if(r12CParam->instance < 0 || r12CParam->instance > MAX_VD7_INSTANCE)
    {
        printf("[PARAMETER] chip instance = %d, out of range(0, %d)\n",r12CParam->instance, MAX_VD7_INSTANCE);
        ret = FALSE;
    }
    else
    {
        printf("[PARAMETER] chip instance = %d\n",r12CParam->instance);
    }

    if(strlen(r12CParam->name) == 0)
    {
        sprintf(r12CParam->name, DEFAULT_VD7_NAME"%d", r12CParam->instance);
    }
    printf("[PARAMETER] name: %s\n",r12CParam->name);

    return ret;
}

#endif
/***********************************************************************
 *
 *  int main( int argc, char *argv[] )
 *
 *  Function:
 *
 *  Entry of R12CPU.
 *
 *  Returns:
 *
 *
 *
 *
 ***********************************************************************/
extern int encInit(void);
extern int shellTaskInit();

int spawnEncInitTask()
{
    char taskname[]="encInit";
    return taskSpawn(taskname, 80, 0, 16 * 1024, (FUNCPTR)encInit, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
}

extern int web_main(char * portName);

//int main( int argc, char *argv[] )
int r12c_main(int instance, char *name)
{
    int ret = TRUE;
    char semName[256];
    HANDLE exitSem;
    struct sigaction sa;
    d7vir_instance_stat_p stat;

    // Print hello
    printf("r12c start!\n");

#if 0
    // Get parameters and save to global variable gR12CParam
    ret = get_arguments(argc, argv, &(gR12CParam));
    if (ret != TRUE)
    {
        r12c_usage();
        return FALSE;
    }
#else
    gR12CParam.instance = instance;

    if(instance < 0 || instance > MAX_VD7_INSTANCE)
    {
        printf("[PARAMETER] chip instance = %d, out of range(0, %d)\n",gR12CParam.instance, MAX_VD7_INSTANCE);
        return FALSE;
    }
    else
    {
        printf("[PARAMETER] chip instance = %d\n",gR12CParam.instance);
    }

    if(strlen(name) == 0)
    {
        sprintf(gR12CParam.name, DEFAULT_VD7_NAME"%d", gR12CParam.instance);
    }
    printf("[PARAMETER] name: %s\n",gR12CParam.name);

#endif

    // Check for required CPU features
    // CPU decode/encode requires AVX and AVX2 extensions
    // (also MMX and the various SSE versions, but can assume if AVX/AVX2
    // are present then MMX and SSE are also)
    // CPU firmware is also requires ABM, BMI, BMI2 extensions as it is
    // built with -mabm -mbmi -mbmi2 to accelerate bit manipulation
    printf("[CPU] %s %s\n", cpuid_get_vendor(), cpuid_get_model());
    if (!cpuid_has_avx())
    {
      printf("[CPU] does not support AVX\n");
      ret = FALSE;
    }
    if (!cpuid_has_avx2())
    {
      printf("[CPU] does not support AVX2\n");
      ret = FALSE;
    }
    if (!cpuid_has_abm())
    {
      printf("[CPU] does not support ABM\n");
      ret = FALSE;
    }
    if (!cpuid_has_bmi())
    {
      printf("[CPU] does not support BMI\n");
      ret = FALSE;
    }
    if (!cpuid_has_bmi2())
    {
      printf("[CPU] does not support BMI2\n");
      ret = FALSE;
    }
    if (!ret)
    {
      printf("[CPU] required features not detected, cannot run r12c\n");
      return FALSE;
    }


    //Open exit sema
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_EXIT_SEMA_NAME"%d", gR12CParam.instance);

    exitSem = osalSemNOpen(semName);
    if(NULL == exitSem)
    {
        printf("[%s] Exit sema %s sem_open failed, errormsg =%s errno=%d\n", __FUNCTION__, semName, strerror(errno), errno);
        return FALSE;
    }

    //Open shared memory
    unsigned long size;
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SHM_NAME"%d", gR12CParam.instance);

    gShmBaseAddr = (unsigned long) osalShMemOpen(semName, &size);
    if(0 == gShmBaseAddr)
    {
        printf("[%s] shm_open failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }

    stat = (d7vir_instance_stat_p)((long)gShmBaseAddr + VD7_SHM_SYSTEM_SUBPARTITION_OFFSET);
    if(stat->redirect)
    {
        sa.sa_flags = SA_SIGINFO;
        sigemptyset(&sa.sa_mask);
        sigaddset(&sa.sa_mask, SIGXFSZ);
        sa.sa_sigaction = sigxfsz_handler;
        if (sigaction(SIGXFSZ, &sa, NULL) == -1)
        {
        }
    }

    // Confirm shared memory size correct
    assert(size == VD7_SHM_PARTITION_SIZE);

    // Save shared memory base addr
    gR12CParam.shmBaseAddr = gShmBaseAddr;

    //Open cfg semahores
    int idx;
    for (idx = 0; idx < MAX_CONFIG_INDEX; idx++)
    {
        memset(semName,0,sizeof(semName));

        // debug chip index 0
        sprintf(semName, VD7_SEM_CFG_TO_HOST_NAME"%d_%d", idx, gR12CParam.instance);

        gR12CParam.r12c_sem_to_host[idx] = osalSemNOpen(semName);

        if(gR12CParam.r12c_sem_to_host[idx] == NULL)
        {
            printf("[%s] CFG sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
            return FALSE;
        }
    }

    // Open error sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_ERR_TO_HOST_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_to_host[VD7_NSEM_ERR]        = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_to_host[VD7_NSEM_ERR] == NULL)
    {
        printf("[%s] ERR sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }

    // Open alarm sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_ALARM_TO_HOST_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_to_host[VD7_NSEM_ALARM]      = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_to_host[VD7_NSEM_ALARM] == NULL)
    {
        printf("[%s] ALARM sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }

    // Open pciein sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_PCIEIN_TO_HOST_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_to_host[VD7_NSEM_PCIEIN]      = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_to_host[VD7_NSEM_PCIEIN] == NULL)
    {
        printf("[%s] PCIEIN sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }


    // Open pcieout sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_PCIEOUT_TO_HOST_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_to_host[VD7_NSEM_PCIEOUT]      = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_to_host[VD7_NSEM_PCIEOUT] == NULL)
    {
        printf("[%s] PCIEOUT sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }


    // Open host to VD7 cfg sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_CFG_TO_D7_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_cfg_to_vd7 = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_cfg_to_vd7 == NULL)
    {
        printf("[%s] HOST to VD7 CFG sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }

    // Open host to VD7 quick cfg sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_CFG_QCK_TO_D7_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_cfg_quick_to_vd7 = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_cfg_quick_to_vd7 == NULL)
    {
        printf("[%s] HOST to VD7 QUICK CFG sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }

    // Open GRC message sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_GRCMSG_TO_HOST_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_to_host[VD7_NSEM_GRCMSG] = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_to_host[VD7_NSEM_GRCMSG] == NULL)
    {
        printf("[%s] GRC message sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }

    // Open DPI status sem
    memset(semName,0,sizeof(semName));
    sprintf(semName, VD7_SEM_DPI_TO_HOST_NAME"%d", gR12CParam.instance);
    gR12CParam.r12c_sem_to_host[VD7_NSEM_DPI] = osalSemNOpen(semName);

    if(gR12CParam.r12c_sem_to_host[VD7_NSEM_DPI] == NULL)
    {
        printf("[%s] DPI sema failed %s, errormsg=%s errno=%d\n", __FUNCTION__,  semName, strerror(errno), errno);
        return FALSE;
    }

    // Take all exit semaphore in case host released more than 1
    while(osalSemNTake(exitSem, NO_WAIT) == 0);


    // Perform stdin/stdout redirection to vuart FIFOs
    osalRedirectIO();

    // Initialize OSWrapper layer
    //OSWrapper_Init();

    // Initialize x86 BSP
    cwBspInit();

    // Init web task
    //WebTaskInit();

    // Start shell task.
    shellTaskInit();


    // Start CWARE initializtion
    // should not call cware api in main thread
    // should call taskspawn to start thread that related to cware
    // other wise the task info is not init
    spawnEncInitTask();


    //Flush vuart output
    fflush(gVuartOutput);


    // Waiting forever on an semaphore instead of exiting the root task
    while(osalSemNTake(exitSem, WAIT_FOREVER) != 0);
    osalSemNClose(exitSem);

    // Close vuart streams
    printf("r12c process exit due to exit semaphore %d\n", 0);

    //fflush(gVuartInput);
    fflush(gVuartOutput);

    // Close vuart input/out
    fclose(gVuartInput);
    fclose(gVuartOutput);

    return ret;
}

