//******************************************************************************
// File:    queues.c
// Purpose: implementation of queues for scheduler
// Author:  M. Thaler, 2012, (based on former work by J. Zeman and M. Thaler)
//          M. Thaler, 2019, CFS
// Version: v.fs20
//******************************************************************************

#include <stdlib.h>
#include <sys/types.h>
#include <sys/times.h>
#include <unistd.h>
#include <stdio.h>

#include "mlist.h"
#include "mthread.h"
#include "queues.h"

//******************************************************************************
// local function prototypes

unsigned mqGetTime(void);
void     mqPrintReadyQueueStatus(void);

//******************************************************************************
// Static data of queueing system

mlist_t*    runQueue;                       // the run queue
mlist_t*    tmpQueue;                       // the run queue

//******************************************************************************
//
// Queueing functions
//
//==============================================================================
// Function:    initQueues
// Purpose:     initialize queueing system
//              behaves like a singleton

static int queueState = 0;

void mqInit(void) {
    if (queueState == 0) {
        runQueue = mlNewList();
        tmpQueue = mlNewList();
        mqGetTime();                        // register start time
        queueState = 1;                     // now we are initialized 
    }
}

//==============================================================================
// Function:    delQueues
// Purpose:     clean up dynamically allocated data
// Hint:        will be called by scheduler before termination

void mqDelete(void) {
    mlDelList(runQueue);
    mlDelList(tmpQueue);
    queueState = 0;
    printf("\n*** cleaning queues ***\n");
}

//==============================================================================
// Function:    getNextThread
// Purpose:     returns thread with highest priority in the run queue
//              if there is no thread, return value is NULL

// compares two threads for sorting
int cmp(void *a, void *b)
{
    mthread_t *ta = (mthread_t *)a;
    mthread_t *tb = (mthread_t *)b;

    if (ta->vRuntime < tb->vRuntime)
    {
        return -1;
    }

    if (ta->vRuntime > tb->vRuntime)
    {
        return 1;
    }

    return 0;
}


mthread_t* mqGetNextThread(void) {
    float offset = 0;
    unsigned NThreads = mlGetNumNodes(runQueue); // Umkopieren der Threads aus runQue in die tmpQueue

    while (mlGetNumNodes(runQueue) > 0) {
      mthread_t* tcb = mlDequeue(runQueue);

      tcb->vRuntime = tcb->vRuntime - (VR_DEFAULT / (NThreads -1)) - offset; // gemäss der Aufgabenstellung: "Vor dem sortierten Einfügen, muss die vRuntime aufdatiert werden"
      mlSortIn(tmpQueue, tcb, *cmp); // sortiertes einfügen

    }

    // Zeiger vertauschen der Queues
    mlist_t *tmp = runQueue;
    runQueue = tmpQueue;
    tmpQueue = tmp;

    mthread_t *tcb = mlDequeue(runQueue); //Return-value in Form des Threads
    //gemäss der Aufgabenstellung: "vRuntime dieses Threads muss in der Variablen offset gespeichert werden, dann kann der Thread an den DIspachter zur Einplandung zurückgegeben werden
    if (tcb != NULL && abs(tcb->vRuntime - tcb->vRuntime) < 0.1) {
        offset = tcb->vRuntime; 
    }

    return tcb;
  
}

//==============================================================================
// Function:    add to queue
// Purpose:     initialize queueing system

void mqAddToQueue(mthread_t *tcb, int sleepTime) {
    tcb->vRuntime += mqGetRuntime() * (mtGetPrio(tcb) + 1); //code aus der Aufgabenstellung, mit der korrekten Priorität (+1)
    mlSortIn(runQueue, tcb, *cmp); //sortiertes Einfügen
}


//==============================================================================
// Function:    printWaitQueue
// Purpose:     prints a the list with threads in the wait queue

void lqPrintWaitQueue(void) {
}

//==============================================================================
// Function:    printReadyQueueStatus
// Purpose:     prints the number of threads in the ready queues at "getTime()"

void mqPrintReadyQueueStatus(void) {
    int i;
    i = mlGetNumNodes(runQueue); // number of threads
    printf("\t\trun queue,  %d entries at time %d\n", i, mqGetTime());
    i = mlGetNumNodes(tmpQueue); // number of threads
    printf("\t\ttmp queue,  %d entries at time %d\n", i, mqGetTime());
}

//******************************************************************************
// Function:    getTime, local function
// Purpose:     returns wall clock time in 1ms resolution since program start
//              works like singleton to register start time of module             

unsigned mqGetTime(void) {
    static int    firstCall = 1;
    static struct timeval startTime;

    struct timeval currentTime;
    unsigned time;

    if (firstCall) {
        gettimeofday(&startTime, NULL);
        firstCall = 0;
    }

    gettimeofday(&currentTime, NULL);
    time = (unsigned)((currentTime.tv_sec  - startTime.tv_sec)*1000 + 
                      (currentTime.tv_usec - startTime.tv_usec)/1000);
    return time;
}

//******************************************************************************

