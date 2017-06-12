#include <stdio.h>
#include <stdlib.h>
#include <omp.h>


void Parallel_sort(int* a,int n,int thread_count)
{
	int i,j,count;
	int* tmp = malloc(n*sizeof(int));
	
	#pragma omp parallel for num_threads(thread_count) \
	default(none) private(i, j, count) shared(a, n, tmp, thread_count)

	for (i = 0; i < n; i++) 
	{
        count = 0;
        for (j = 0; j < n; j++)
        {
            if (a[j] < a[i])
               count++;
            else if (a[j] == a[i] && j < i)
               count++;
       	}
        tmp[count] = a[i];
     }

	memcpy(a,tmp,n*sizeof(int));
	free(tmp);
}

void fill_vec(int* a,int n)
{
	srand(time(NULL));
	int i;
	for(i=0;i<n;i++)
	{
		a[i] = rand()%20+1;
	}

}

void print_vec(int* a,int n)
{
	int i;
	for(i=0;i<n;i++)
	{
		printf("%d ",a[i]);
	}
	printf("\n");

}


int main(int argc,char* argv[])
{

	int thread_count = strtol(argv[1],NULL,10);
	int n_elems = 10000000;
	int my_size = n_elems*sizeof(int);
	int* vec = (int*) malloc(my_size);
	fill_vec(vec,n_elems);

	printf("Parallel count sort...\n");
	Parallel_sort(vec,n_elems,thread_count);
	print_vec(vec,n_elems);

	free(vec);
	return 0;
}