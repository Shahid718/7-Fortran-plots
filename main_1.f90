!------------------------------------------------------------------------
!
!
!   The program shows how to use modified Quick DISLIN plots
!
!   Author  :
!               Shahid Maqbool
!
!   Modified   :
!                    06 October 2023
!
!   To compile and run :
!                            check ReadMe file
!
!------------------------------------------------------------------------



program ch_dislin_test
  use Dislin
  implicit none


  ! =====================================================================
  !                              parameters
  ! =====================================================================



  integer , parameter :: Nx = 64, Ny = 64, dx = 1, dy = 1, nsteps = 5000
  real , parameter :: c0 = 0.4,  mobility = 1.0, grad_coef = 0.5
  real , parameter :: dt = 0.01, noise = 0.02,  A  = 1.0
  real , dimension ( Nx, Ny ) :: r, con, lap_con, dfdcon
  real , dimension ( Nx, Ny ) :: dummy_con, lap_dummy
  integer  :: i, j, jp, jm, ip, im, istep
  integer , parameter   :: N = 5, NN = 100
  real , dimension(1:N) :: radius
  real , parameter :: start_value = -0.1, end_value = 1.1
  real , parameter :: increment = ( end_value - start_value )/( NN - 1 ) 
  real , dimension(1:NN) :: c, F


  c = [( start_value + ( i - 1 )*increment, i = 1,NN ) ]
  F = A*( ( c**2 )*( 1 - c )**2 )        
  radius = [ 0.2, 0.5, 0.8, 0.1, 0.7 ]


  ! =====================================================================
  !                           initial microstructure
  ! =====================================================================


  call random_number ( r )
  con = c0 + noise*( 0.5 - r )


  ! =====================================================================
  !                        start microstructure evolution
  ! =====================================================================



  time_loop: do istep = 1, nsteps


     do concurrent ( i=1:Nx, j=1:Ny )


        ! free energy derivative

        dfdcon(i,j) = A*( 2.0*con(i,j)*( 1.0 - con(i,j) )**2 &
             - 2.0*con(i,j)**2*( 1.0 - con(i,j) ) )


        ! laplace evaluation

        jp = j + 1
        jm = j - 1
        ip = i + 1
        im = i - 1

        if ( im == 0 ) im = Nx
        if ( ip == ( Nx + 1) ) ip = 1
        if ( jm == 0 ) jm = Ny
        if ( jp == ( Ny + 1) ) jp = 1

        lap_con(i,j)   = ( con(ip,j) + con(im,j) + con(i,jm) &
             & + con(i,jp) - 4.0*con(i,j) ) /( dx*dy )

        dummy_con(i,j) = dfdcon(i,j) - grad_coef*lap_con(i,j)

        lap_dummy(i,j) = ( dummy_con(ip,j) + dummy_con(im,j) + &
             & dummy_con(i,jm) + dummy_con(i,jp) - &
             & 4.0*dummy_con(i,j) ) / ( dx*dy )


        ! time integration

        con(i,j) =  con(i,j) + dt*mobility*lap_dummy(i,j)


        ! for small deviations

        if ( con(i,j) >= 0.99999 )  con(i,j) = 0.99999
        if ( con(i,j) < 0.00001 )   con(i,j) = 0.00001



     end do


  end do time_loop



  ! =====================================================================
  !                      modified dislin quick plots
  ! =====================================================================


  call METAFL ('png')
  call SCRMOD ('revers')
  call DISINI
  call NAME ('c', 'X')
  call NAME ('F', 'Y')
  call TITLIN ('Free Energy', 2)  
  call QPLOT  ( c, F, NN )


  call METAFL ('png')
  call SCRMOD ('revers')
  call DISINI
  call NAME ('c', 'X')
  call NAME ('F', 'Y')
  call TITLIN ('Free Energy Scattered Plot', 2)
  call QPLSCA ( c, F, NN )


  call METAFL ('png')
  call SCRMOD ('revers')
  call DISINI
  call NAME ('Nx', 'X')
  call NAME ('Ny', 'Y')
  call TITLIN ('Color plot', 2)  
  call QPLCLR ( con, Nx, Ny )


  call METAFL ('png')
  call SCRMOD ('revers')
  call DISINI
  call NAME ('Nx', 'X')
  call NAME ('Ny', 'Y')
  call TITLIN ('Contour plot', 2)  
  call QPLCON ( con, Nx, Ny, 6 )


  call METAFL ('png')
  call SCRMOD ('revers')
  call DISINI
  call NAME ('Nx', 'X')
  call NAME ('Ny', 'Y')
  call TITLIN ('Surface plot', 2)  
  call QPLSUR ( con, Nx, Ny )


  call METAFL ('png')
  call SCRMOD ('revers')
  call DISINI
  call NAME ('N', 'X')
  call NAME ('radius', 'Y')
  call TITLIN ('Bar chart of radius', 2)  
  call QPLBAR ( radius, N )


  call METAFL ('png')
  call SCRMOD ('revers')
  call DISINI
  call NAME ('N', 'X')
  call NAME ('radius', 'Y')
  call TITLIN ('Pie chart of radius', 2)  
  call QPLPIE ( radius, N )



end program ch_dislin_test
