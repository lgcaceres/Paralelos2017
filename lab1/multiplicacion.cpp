#include <iostream>
#include <chrono>
using namespace std;

const int m_size = 720;


void llenar_matrix(int m[][m_size],int n,int elem)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            m[i][j]=elem;
        }
    }
}

void mostrar_matrix(int m[][m_size],int n)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            cout<<m[i][j]<<" ";
        }
        cout<<endl;
    }
}



void block_mult(int m1[][m_size],int m2[][m_size],int r[][m_size],int n,int block_num)
{
    int block_size = n/block_num;

    for(int ii=0;ii<n;ii+=block_size)
    {
        for(int jj=0;jj<n;jj+=block_size)
        {
            for(int kk=0;kk<n;kk+=block_size)
            {
                for(int i=ii;i<ii+block_size;i++)
                {
                    for(int j=jj;j<jj+block_size;j++)
                    {
                        for(int k=kk;k<kk+block_size;k++)
                        {
                            r[i][j] += m1[i][k]*m2[k][j];
                        }
                    }
                }
            }
        }
    }

}

void mult__secuencial_matrix(int m1[][m_size],int m2[][m_size],int r[][m_size],int n)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            r[i][j]=0;
            for(int k=0;k<n;k++)
            {
                r[i][j]+=m1[i][k]*m2[k][j];
            }
        }
    }
}

int main()
{
	

	int m1[m_size][m_size];
    llenar_matrix(m1,m_size,2);
    int m2[m_size][m_size];
    llenar_matrix(m2,m_size,2);
    int r[m_size][m_size];
    llenar_matrix(r,m_size,0);

    auto _start = chrono::system_clock::now();

    
    block_mult(m1,m2,r,m_size,3);

    auto _end = chrono::system_clock::now();

    auto elapsed = chrono::duration_cast<chrono::microseconds>(_end - _start);
    cout<<"Tiempo de ejecucion: "<<elapsed.count()<<endl;
	return 0;
}
