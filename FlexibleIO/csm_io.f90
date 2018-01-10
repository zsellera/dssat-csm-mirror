!=======================================================================
! csm_io.f90, Felipe de Vargas, Willingthon Pavan
! Fortran getters and setters subroutines to calling functions in c++.
!-----------------------------------------------------------------------
! REVISION HISTORY
! 07/10/2016 FV Written.
! 09/01/2016 FV Create get's for read weather data.
! 09/25/2016 FV Create set's for write data in memory.
! 06/18/2017 FV Create new version of getters for weather data.
! 12/04/2017 FO Added a parameter in the functions for the new FlexibleIO data structure
! 12/11/2017 FO Added variable to return error code in readweather subroutine.
!========================================================================
module class_ioset
    type csm_io_type
    contains
        procedure :: set_io_val_real
        procedure :: set_io_val_int
        procedure :: set_io_val_char
        procedure :: set_io_val_real_mem
        procedure :: set_io_val_char_mem
        procedure :: set_io_val_int_mem
        procedure :: set_io_val_real_mem_ind
        procedure :: set_io_val_char_mem_ind
        procedure :: set_io_val_int_mem_ind
        procedure :: set_io_val_int_mem_yrdoy
        procedure :: set_io_val_real_mem_yrdoy
        procedure :: set_io_val_char_mem_yrdoy

        procedure :: get_io_val_real
        procedure :: get_io_val_int
        procedure :: get_io_val_char
        procedure :: get_io_val_real_array
        procedure :: get_io_val_int_array
        procedure :: get_io_val_real_ind
        procedure :: get_io_val_int_ind
        procedure :: get_io_val_char_ind
        procedure :: get_io_val_real_yrdoy
        procedure :: get_io_val_int_yrdoy
        procedure :: get_io_val_char_yrdoy

        generic :: set => set_io_val_real, set_io_val_int, &
        set_io_val_char, set_io_val_real_mem, set_io_val_char_mem, &
        set_io_val_int_mem, set_io_val_real_mem_ind, set_io_val_char_mem_ind, &
        set_io_val_int_mem_ind, set_io_val_int_mem_yrdoy, set_io_val_real_mem_yrdoy, &
        set_io_val_char_mem_yrdoy
        generic :: get => get_io_val_real, get_io_val_int, &
        get_io_val_char, get_io_val_real_array, &
        get_io_val_int_array, &
        get_io_val_real_ind, get_io_val_int_ind, get_io_val_char_ind, &
        get_io_val_real_yrdoy, get_io_val_int_yrdoy, get_io_val_char_yrdoy
    end type csm_io_type

contains

    subroutine get_io_val_real(ioset, modinp, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        real, intent(out) :: val
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine get_real(modinp, vname, val)&
                bind(C, name = 'getReal')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                REAL :: val
            end subroutine get_real
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_real(modaux, aux, val)

    end subroutine get_io_val_real

    subroutine get_io_val_int(ioset, modinp, vname, val)

        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_int(modinp, vname, val)&
                bind(C, name = 'getInt')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                INTEGER :: val
            end subroutine get_int
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_int(modaux, aux, val)

    end subroutine get_io_val_int

    subroutine get_io_val_char(ioset, modinp, vname, val)

        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        character(len = *), intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_char(modinp, vname, val)&
                bind(C, name = 'getChar')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                character(kind = c_char), dimension(*) :: val
            end subroutine get_char
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_char(modaux, aux, val)

    end subroutine get_io_val_char


    subroutine get_io_val_real_array(ioset, modinp, vname, val, size)


        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: size
        real, dimension(:), intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_real_array(modinp, vname, val, size)&
                bind(C, name = 'getRealArray')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                real, dimension(*) :: val
                integer :: size
            end subroutine get_real_array
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_real_array(modaux, aux, val, size)

    end subroutine get_io_val_real_array

    subroutine get_io_val_int_array(ioset, modinp, vname, val, size)


        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: size
        integer, dimension(:), intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_int_array(modinp, vname, val, size)&
                bind(C, name = 'getIntArray')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer, dimension(*) :: val
                integer :: size
            end subroutine get_int_array
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_int_array(modaux, aux, val, size)

    end subroutine get_io_val_int_array

    subroutine get_io_val_real_ind(ioset, modinp, vname, val, ind)


        use, INTRINSIC :: iso_c_binding

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: ind
        real, intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_real(modinp, vname, val, ind)&
                bind(C, name = 'getRealInd')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer :: ind
                REAL :: val
            end subroutine get_real
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_real(modaux, aux, val, ind)

    end subroutine get_io_val_real_ind

    subroutine get_io_val_int_ind(ioset, modinp, vname, val, ind)

        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: ind
        integer, intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_int_ind(modinp, vname, val, ind)&
                bind(C, name = 'getIntInd')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                INTEGER :: val
                INTEGER :: ind
            end subroutine get_int_ind
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_int_ind(modaux, aux, val, ind)

    end subroutine get_io_val_int_ind

    subroutine get_io_val_char_ind(ioset, modinp, vname, val, ind)

        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: ind
        character(len = *), intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        CHARACTER(len = 100) aux2
        character*25 modaux

        interface
            subroutine get_char_ind(modinp, vname, val, ind)&
                bind(C, name = 'getCharInd')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                character(kind = c_char), dimension(*) :: val
                integer :: ind
            end subroutine get_char_ind
        end interface
        aux = vname // "="
        modaux = modinp // "="
        val = ""

        call get_char_ind(modaux, aux, val, ind)

    end subroutine get_io_val_char_ind

    subroutine get_io_val_real_yrdoy(ioset, modinp, yrdoy, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: yrdoy
        real, intent(out) :: val
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine get_real_yrdoy(modinp, yrdoy, vname, val)&
                bind(C, name = 'getRealYrdoy')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                REAL :: val
                INTEGER :: yrdoy
            end subroutine get_real_yrdoy
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_real_yrdoy(modaux, yrdoy, aux, val)

    end subroutine get_io_val_real_yrdoy

    subroutine get_io_val_int_yrdoy(ioset, modinp, yrdoy, vname, val)

        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: yrdoy
        integer, intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_int_yrdoy(modinp, yrdoy, vname, val)&
                bind(C, name = 'getIntYrdoy')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                INTEGER :: val, yrdoy
            end subroutine get_int_yrdoy
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_int_yrdoy(modaux, yrdoy, aux, val)

    end subroutine get_io_val_int_yrdoy

    subroutine get_io_val_char_yrdoy(ioset, modinp, yrdoy, vname, val)

        implicit none

        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: yrdoy
        character(len = *), intent(out) :: val
        class(csm_io_type) :: ioset

        character*100 aux
        character*25 modaux

        interface
            subroutine get_char_yrdoy(modinp, yrdoy, vname, val)&
                bind(C, name = 'getCharYrdoy')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                character(kind = c_char), dimension(*) :: val
                integer yrdoy
            end subroutine get_char_yrdoy
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call get_char_yrdoy(modaux, yrdoy, aux, val)

    end subroutine get_io_val_char_yrdoy



    subroutine set_io_val_real(ioset, modinp, vname, val, idetg, file)

        implicit none

        character(len = *), intent(in) :: modinp
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: idetg
        real, intent(in) :: val
        character(len = *), intent(in) :: file
        class(csm_io_type) :: ioset
        character*100 aux, aux2
        character*1 auxidetg
        character*25 modaux


        interface
            subroutine set_io_real(modinp, vname, val, idetg, file)&
                bind(C, name = 'setReal')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                character(kind = c_char), dimension(*) :: file
                real :: val
                character*1 :: idetg
            end subroutine set_io_real
        end interface
        auxidetg = idetg
        aux = vname // "="
        aux2 = file // "="
        modaux = modinp // "="

        !call set_io_real(modaux, aux,val,auxidetg,aux2)
    end subroutine set_io_val_real

    subroutine set_io_val_int(ioset, modinp, vname, val, idetg, file)

        implicit none
        
        character(len = *), intent(in) :: modinp
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: idetg
        integer, intent(in) :: val
        character(len = *), intent(in) :: file
        class(csm_io_type) :: ioset
        character*100 aux, aux2
        character*1 auxidetg
        character*25 modaux

        interface
            subroutine set_io_int(modinp, vname, val, idetg, file)&
                bind(C, name = 'setInt')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                character(kind = c_char), dimension(*) :: file
                integer :: val
                character*1 :: idetg
            end subroutine set_io_int
        end interface
        auxidetg = idetg
        aux = vname // "="
        aux2 = file // "="
        modaux = modinp // "="

        !        call set_io_int(modaux, aux,val,auxidetg,aux2)

    end subroutine set_io_val_int

    subroutine set_io_val_char(ioset, modinp, vname, val, idetg, title, file)

        implicit none

        character(len = *), intent(in) :: modinp
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: idetg
        character(len = *), intent(in) :: title
        character(len = *), intent(in) :: val
        character(len = *), intent(in) :: file
        class(csm_io_type) :: ioset
        character*200 aux, auxval, aux2
        character*1 auxidetg
        character*25 modaux

        interface
            subroutine set_io_char(modinp, vname, val, idetg, title, file)&
                bind(C, name = 'setChar')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: modinp
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: val
                character(kind = c_char), dimension(*) :: file
                character*1 :: idetg
                character*1 :: title
            end subroutine set_io_char
        end interface
        auxidetg = idetg
        aux = vname // "="
        auxval = val // "="
        aux2 = file // "="
        modaux = modinp // "="

        !call set_io_char(modaux, aux,auxval,auxidetg,title,aux2)



    end subroutine set_io_val_char

    subroutine set_io_val_real_mem(ioset, modinp, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        real, intent(in) :: val
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine set_real_mem(modinp, vname, val)&
                bind(C, name = 'setRealMem')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                REAL :: val
            end subroutine set_real_mem
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call set_real_mem(modaux, aux, val)
    end subroutine set_io_val_real_mem

    subroutine set_io_val_char_mem(ioset, modinp, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: val
        character(len = *), intent(in) :: modinp
        class(csm_io_type) :: ioset
        character*100 aux, aux2
        character*25 modaux

        interface
            subroutine set_char_mem(modinp, vname, val)&
                bind(C, name = 'setCharMem')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: val
                character(kind = c_char), dimension(*) :: modinp
            end subroutine set_char_mem
        end interface
        aux = vname // "="
        aux2 = val // "="
        modaux = modinp // "="
        
        call set_char_mem(modaux, aux, aux2)
    end subroutine set_io_val_char_mem

    subroutine set_io_val_int_mem(ioset, modinp, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: val
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine set_int_mem(modinp, vname, val)&
                bind(C, name = 'setIntMem')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer :: val
            end subroutine set_int_mem
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call set_int_mem(modaux, aux, val)
    end subroutine set_io_val_int_mem
    subroutine set_io_val_real_mem_ind(ioset, modinp, vname, val, ind)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        real, intent(in) :: val
        integer, intent(in) :: ind
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine set_real_mem_ind(modinp, vname, val, ind)&
                bind(C, name = 'setRealMemInd')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer :: ind
                REAL :: val
            end subroutine set_real_mem_ind
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call set_real_mem_ind(modaux, aux, val, ind)
    end subroutine set_io_val_real_mem_ind

    subroutine set_io_val_char_mem_ind(ioset, modinp, vname, val, ind)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: val
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: ind
        class(csm_io_type) :: ioset
        character*100 aux, aux2
        character*25 modaux

        interface
            subroutine set_char_mem_ind(modinp, vname, val, ind)&
                bind(C, name = 'setCharMemInd')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: val
                character(kind = c_char), dimension(*) :: modinp
                integer :: ind
            end subroutine set_char_mem_ind
        end interface
        aux = vname // "="
        aux2 = val // "="
        modaux = modinp // "="
        
        call set_char_mem_ind(modaux, aux, aux2, ind)
    end subroutine set_io_val_char_mem_ind

    subroutine set_io_val_int_mem_ind(ioset, modinp, vname, val, ind)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: val
        integer, intent(in) :: ind
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine set_int_mem_ind(modinp, vname, val, ind)&
                bind(C, name = 'setIntMemInd')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer ind
                integer :: val
            end subroutine set_int_mem_ind
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call set_int_mem_ind(modaux, aux, val, ind)
    end subroutine set_io_val_int_mem_ind

    subroutine set_io_val_int_mem_yrdoy(ioset, modinp, yrdoy, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: val
        integer, intent(in) :: yrdoy
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine set_int_mem_yrdoy(modinp, yrdoy, vname, val)&
                bind(C, name = 'setIntMemYrdoy')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer yrdoy
                integer :: val
            end subroutine set_int_mem_yrdoy
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call set_int_mem_yrdoy(modaux, yrdoy, aux, val)
    end subroutine set_io_val_int_mem_yrdoy

    subroutine set_io_val_real_mem_yrdoy(ioset, modinp, yrdoy, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: modinp
        real, intent(in) :: val
        integer, intent(in) :: yrdoy
        class(csm_io_type) :: ioset
        character*100 aux
        character*25 modaux

        interface
            subroutine set_real_mem_yrdoy(modinp, yrdoy, vname, val)&
                bind(C, name = 'setRealMemYrdoy')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer yrdoy
                real :: val
            end subroutine set_real_mem_yrdoy
        end interface
        aux = vname // "="
        modaux = modinp // "="

        call set_real_mem_yrdoy(modaux, yrdoy, aux, val)
    end subroutine set_io_val_real_mem_yrdoy

    subroutine set_io_val_char_mem_yrdoy(ioset, modinp, yrdoy, vname, val)

        use, INTRINSIC :: iso_c_binding
        character(len = *), intent(in) :: vname
        character(len = *), intent(in) :: val
        character(len = *), intent(in) :: modinp
        integer, intent(in) :: yrdoy
        class(csm_io_type) :: ioset
        character*100 aux, aux2
        character*25 modaux

        interface
            subroutine set_char_mem_yrdoy(modinp, yrdoy, vname, val)&
                bind(C, name = 'setCharMemYrdoy')
                use, intrinsic :: iso_c_binding
                character(kind = c_char), dimension(*) :: vname
                character(kind = c_char), dimension(*) :: modinp
                integer yrdoy
                character(kind = c_char), dimension(*) :: val
            end subroutine set_char_mem_yrdoy
        end interface
        aux = vname // "="
        aux2 = val // "="
        modaux = modinp // "="

        call set_char_mem_yrdoy(modaux, yrdoy, aux, aux2)
    end subroutine set_io_val_char_mem_yrdoy


end module class_ioset


module csm_io

    use class_ioset

    implicit none

    type(csm_io_type) :: csminp

end module csm_io

SUBROUTINE FINDJSON(FILEX, JSONEXIST)

    use, INTRINSIC :: iso_c_binding
    CHARACTER, dimension(*) :: FILEX
    INTEGER JSONEXIST

    interface
        subroutine findjson_(FILEX, JSONEXIST) bind(C, name = 'findJson')
            import :: c_char
            CHARACTER, dimension(*) :: FILEX
            INTEGER :: JSONEXIST
        end subroutine findjson_
    end interface

    call findjson_(FILEX, JSONEXIST)

END SUBROUTINE FINDJSON

SUBROUTINE READWEATHER(FILEWTH, YRDOYWY, YRDOY, YRSIM, MULTI, ENDFILE, FILEX, MODEL, DAYBEFORE, ERRORNUM)
    use, INTRINSIC :: iso_c_binding
    CHARACTER, dimension(*) :: FILEWTH
    CHARACTER, dimension(*) :: FILEX
    CHARACTER, dimension(*) :: MODEL
    integer YRDOYWY, YRDOY, YRSIM, MULTI, ENDFILE, DAYBEFORE, ERRORNUM

    interface
        subroutine readwth_(fileW, yrdoywy, yrdoy, yrsim, multi, endfile, fileX, model, daybefore, errnum)&
            bind(C, name = 'readw_')
            import :: c_char
            character(kind = c_char), dimension(*) :: fileW
            character(kind = c_char), dimension(*) :: fileX
            character(kind = c_char), dimension(*) :: model
            integer :: yrdoywy
            integer :: yrdoy
            integer :: yrsim
            integer :: multi
            integer :: endfile
            integer :: daybefore
            integer :: errnum
        end subroutine readwth_
    end interface
    SAVE

    call readwth_(FILEWTH, YRDOYWY, YRDOY, YRSIM, MULTI, ENDFILE, FILEX, MODEL, DAYBEFORE, ERRORNUM)
END SUBROUTINE READWEATHER
