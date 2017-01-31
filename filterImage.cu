#include "imageProcessing.h"
#include "globalVars.h"
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "common.h"

__global__
void myKernel(unsigned char *out,unsigned char *im, long int taille){
 
    int idx =blockIdx.x * blockDim.x +threadIdx.x;
        
	int reduceVal=50;
	
	if (idx <taille) {
		if(im[idx]>reduceVal){
			out[idx]=im[idx]/2;
		}else{
      			out[idx] =0;
		}
    } 	
}
/*
void filterImage_Cuda(unsigned char *out, unsigned char *im, int im_step, int im_cols, int im_rows){
double tstart, tend;
//cudaPrintfInit();
dim3 threads(1,2,3);
dim3 blocks(1,1,4);

unsigned char *cout, *cim;

cudaSetDevice(0);
cudaMalloc((void **)&cout, sizeof(unsigned char)*(im_cols*im_rows));
cudaMalloc((void **)&cim, sizeof(unsigned char)*(im_cols*im_rows));

cudaMemcpy(cout, out, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyHostToDevice);
cudaMemcpy(cim, im, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyHostToDevice);

tstart = wallclock();
printf("We going to the kernel \n" );
printf(" %d \n and %d \n",im_cols,im_rows);
kernel<<< blocks, threads >>>(cout,cim,(im_cols*im_rows));
tend = wallclock();
printf("Time for kernel call is :%f milliseconds \n" , (tend-tstart)*1000.0 );

cudaMemcpy(out, cout, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyDeviceToHost);
cudaMemcpy(im, cim, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyDeviceToHost);

cudaFree(cout);
cudaFree(cim);

}
*/

/* 
 * Filter before matching 
 
void filterImage_Cuda(unsigned char *out, unsigned char *im, int im_step, int im_cols, int im_rows){
  if (!im || !out) return;
  ///// TO BE FILLED

#pragma acc kernels pcopyin(im[0:im_cols*im_rows]) pcopyout(out[0:im_cols*im_rows]) 
  {
#pragma acc loop independent
    for (int idx = 0; idx < im_cols*im_rows; idx++){
      int reduceVal = 50;
      if (im[idx] > reduceVal) out[idx] = im[idx] - reduceVal; 
      else out[idx] = 0;
    }
  }
}

*/
void filterImage(unsigned char *out, unsigned char *im, int im_step, int im_cols, int im_rows){
  if (!im || !out) return;

  for(int i = 3;i < im_rows-3;i++){
    for(int j = 3;j < im_cols-3;j++){
      double v1 = (2047.0 *(im[INDXs(im_step,i,j+1)] - im[INDXs(im_step,i,j-1)])
		   +913.0 *(im[INDXs(im_step,i,j+2)] - im[INDXs(im_step,i,j-2)])
		   +112.0 *(im[INDXs(im_step,i,j+3)] - im[INDXs(im_step,i,j-3)]))/8418.0;
      //v1 is not in the range NEED FIXING
      out[INDXs(im_step,i,j)] = v1;
    }
  }
}

void filterImage(float *out, float *im, int im_step, int im_cols, int im_rows){
  if (!im || !out) return;

  for(int i = 3;i < im_rows-3;i++){
    for(int j = 3;j < im_cols-3;j++){
      double v1 = (2047.0 *(im[INDXs(im_step,i,j+1)] - im[INDXs(im_step,i,j-1)])
                   +913.0 *(im[INDXs(im_step,i,j+2)] - im[INDXs(im_step,i,j-2)])
                   +112.0 *(im[INDXs(im_step,i,j+3)] - im[INDXs(im_step,i,j-3)]))/8418.0;
      //v1 is not in the range NEED FIXING                                                                                        
      out[INDXs(im_step,i,j)] = v1;
    }
  }
}
 
cv::Mat *filterImage(cv::Mat *image){

  cv::Mat *filtered = NULL;
  if (!image) return filtered;
  //Deep copy of the original                                                                                                                                                                                                         
  filtered = new cv::Mat(image->clone());
  unsigned char *fil = (unsigned char*)(filtered->data);

  unsigned char *im = (unsigned char*)(image->data);
  int im_step = image->step;
  int im_cols = image->cols;
  int im_rows = image->rows;
	 double tstart, tend;
	//cudaPrintfInit();
	dim3 threads(im_cols);
 	dim3 blocks(im_rows);

	unsigned char *cout,*cim;

	cudaSetDevice(0);
	cudaMalloc((void **)&cout, sizeof(unsigned char)*(im_cols*im_rows));
	cudaMalloc((void **)&cim, sizeof(unsigned char)*(im_cols*im_rows));
	
	cudaMemcpy(cim,im, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyHostToDevice);
	cudaMemcpy(cout,fil, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyHostToDevice);

	printf("We going to the kernel \n" );
	printf(" %d \n and %d \n",im_cols,im_rows);
	
	tstart = wallclock();
	myKernel<<< blocks, threads >>>(cout,cim,(im_cols*im_rows));
	tend = wallclock();

	printf("Time for kernel call is :%f milliseconds \n" , (tend-tstart)*1000.0 );

	cudaMemcpy(fil, cout, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyDeviceToHost);
	//cudaMemcpy(cim, im, sizeof(unsigned char)*(im_cols*im_rows), cudaMemcpyDeviceToHost);
	cudaFree(cout);
	cudaFree(cim);
  
	filtered->data=fil;
	//filterImage_Cuda(fil,im,im_step,im_cols,im_rows);
        return filtered;
}


void  filterImages(){
  for (int i=0; i< nbImages; i++){
    image_gray[i] = *filterImage(&image_gray[i]);
  }
}

void filterSamples(){
  for (int i=0; i< nbSamples; i++){
    sample_gray[i] = *filterImage(&sample_gray[i]);
  }
}
