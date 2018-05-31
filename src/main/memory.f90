module memory
 implicit none

contains

 !
 !--Allocate all allocatable arrays: mostly part arrays, and tree structures
 !
 subroutine allocate_memory(n, part_only)
  use io, only:iprint,error,fatal
  use dim, only:update_max_sizes,maxp_hard
  use allocutils, only:nbytes_allocated,bytes2human
  use part, only:allocate_part
  use kdtree, only:allocate_kdtree
  use linklist, only:allocate_linklist

   integer,           intent(in) :: n
   logical, optional, intent(in) :: part_only

   logical :: part_only_
   character(len=11) :: sizestring

   if (n > maxp_hard) call fatal('memory', 'Trying to allocate above maxp hard limit.')

   if (present(part_only)) then
     part_only_ = part_only
   else
     part_only_ = .false.
   endif

   call update_max_sizes(n)

   write(iprint, *)
   if (part_only_) then
     write(iprint, '(a)') '--> ALLOCATING PART ARRAYS'
   else
     write(iprint, '(a)') '--> ALLOCATING ALL ARRAYS'
   endif
   write(iprint, '(a)') '---------------------------------------------------------'

   if (nbytes_allocated > 0.0) then
      call error('part', 'Attempting to allocate memory, but memory is already allocated. &
      & Deallocating and then allocating again.')
      call deallocate_memory(part_only=part_only_)
   endif

   call allocate_part
   if (.not. part_only_) then
     call allocate_kdtree
     call allocate_linklist
   endif

   call bytes2human(nbytes_allocated, sizestring)
   write(iprint, '(a)') '---------------------------------------------------------'
   write(iprint, *) 'Total memory allocated to arrays: ', sizestring
   write(iprint, '(a)') '---------------------------------------------------------'

 end subroutine allocate_memory

 subroutine deallocate_memory(part_only)
    use part, only:deallocate_part
    use kdtree, only:deallocate_kdtree
    use linklist, only:deallocate_linklist

    logical, optional, intent(in) :: part_only
    logical :: part_only_

    if (present(part_only)) then
      part_only_ = part_only
    else
      part_only_ = .false.
    endif

    call deallocate_part
    if (.not. part_only_) then
      call deallocate_kdtree
      call deallocate_linklist
    endif
 end subroutine deallocate_memory

end module memory
