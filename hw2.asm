################################################################################################################ 
################################################################################################################
#####   HW #2 CS465 Jenifer Cochran & Renzo Tejada
#####   Due Date 						03/04/2016  
#####   Description: Program prompts user for 2 integer inputs a and b
#####                Returns the GCD of inputs a and b in the form gcd(a,b) = g * (2^d)
################################################################################################################ 
################################################################################################################ 


.data

promptA: .asciiz "Please enter an integer (a):\n"
promptB: .asciiz "Please enter an integer (b):\n"
gcd:     .asciiz "gcd("
endPar:  .asciiz ")"
comma:   .asciiz ","
equals:  .asciiz ") = "
times2:  .asciiz " *(2^"

.text

  jal getIntegersAandB
  #save a and b
  add $s0, $v0, $0  #save a into $s0
  add $s1, $v1, $0  #save b into $s1
  #move integers a and b into arguement registers
  add $a0, $v0, $0  #move integer a to $a0
  add $a1, $v1, $0  #move integer b to $a1
  jal getGCD
  #save g and d
  add $s2, $v0, $0  #save g into $s2
  add $s3, $v1, $0  #save d into $s3
  #move a, b, g, d into argument registers
  add $a0, $s0, $0  #move a to a0
  add $a1, $s1, $0  #move b to a1
  add $a2, $s2, $0  #move g to a2
  add $a3, $s3, $0  #move d to a3
  jal print
  j   exit
  
################################################################################################################
#####   Procedure: Get Integers
#####   Info:      get integers a and b from user
#####              and put them into registers $v0, $v1
################################################################################################################   
getIntegersAandB: 
      #set up stack pointer
      addi $sp, $sp, -4     #allocate stack frame of 4 bytes
      sw   $ra, 0($sp)      #save return address
      #get integer A
      la   $a0, promptA     # load address of prompt for syscall
      li   $v0, 4           # specify Print String service
      syscall               # print the promptA string
      li   $v0, 5           # specify Read Integer service, 5 is to read integers
      syscall               # Read the number. After this instruction, the number read is in $v0.
      add $t0, $v0, $zero   # transfer the number to the desired register 
      #get integer B 
      la   $a0, promptB     # load address of prompt for syscall
      li   $v0, 4           # specify Print String service
      syscall               # print the promptB string
      li   $v0, 5           # specify Read Integer service, 5 is to read integers
      syscall               # Read the number. After this instruction, the number read is in $v0.
      add $t1, $v0, $zero   # transfer the number to the desired register 
      #put a and b into return variables
      add $v0, $t0, $zero   #transfer a to the return variable $v0
      add $v1, $t1, $zero   #transfer b to the return variable $v1
      #restore stack 
      lw   $ra, 0($sp)      #restore return address
      addi $sp, $sp, 4      #free stack frame
      #return to caller
      jr $ra                #return to caller


###################################################################################
#####   Procedure: Get GCD (using binary_gcd algorithm)
#####   Reference: en.wikipedia.org/wiki/Greatest_common_divisor#Binary_method)
#####   Info:      uses values a and b in registers $a0 and $a1
#####              and calculates g and d and puts them in registers $v0 and $v1
###################################################################################
getGCD:
      #set up stack
      addi $sp, $sp, -4     #allocate stack frame of 4 bytes
      sw   $ra, 0($sp)      #save return address
      #gcd binary algorithm
      add $v1, $0, $0       #set d = 0
      #while a and b are both even do
loop: and $t1, $a0, 0x01    #check if a is even ($t1 = 0 even otherwise odd)
      and $t2, $a1, 0x01    #check if b is even ($t2 = 0 even otherwise odd)
      seq $t3, $t1, $0      #is a even?
      seq $t4, $t2, $0      #is b even?
      and $t5, $t3, $t4     #is both a and b even?
      bne $t5, 1, nextloop  #if both a and b are not even, then go to next loop
      sra $a0, $a0, 1       #a/2
      sra $a1, $a1, 1       #b/2
      add $v1, $v1, 1       #d = d + 1
      j   loop
      #while a != b do
nextloop:
      beq $a0, $a1, output  # if a == b 
      and $t1, $a0, 0x01    #check if a is even ($t1 = 0 even otherwise odd)
      and $t2, $a1, 0x01    #check if b is even ($t2 = 0 even otherwise odd)
      sle $t3, $a0, $a1     #set if a <= b  ($t3= 0 if a>b otherwise 1)
      #if a is even then a = a/2
aIsEven:
      bne $t1, $0, bIsEven  #if a is even continue, otherwise go to next if
      sra $a0, $a0, 1       #a/2
      j nextloop
      #else if b is even then b = b/2
bIsEven:
      bne $t2, $0, aGTb     #if b is even continue, otherwise go to next if
      sra $a1, $a1, 1       #b/2
      j nextloop
      #else if a > b then a = (a-b)/2
aGTb:
      bne $t3, $0, else   #if a > b continue, otherwise go to else
      sub $a0, $a0, $a1   #a-b
      sra $a0, $a0, 1     #(a-b)/2
      j nextloop
      #else b = (b-a)/2
else:
      sub $a1, $a1, $a0  # b - a
      sra $a1, $a1, 1    #(b-a)/2
      j nextloop
output:
      add $v0, $a0, $0    #g = a put it as a return
      #restore stack 
      lw   $ra, 0($sp)  #restore return address
      addi $sp, $sp, 4  #free stack frame
      #return to caller
      jr $ra            #return to caller 

###################################################################################
#####   Procedure: print "gcd(a,b) = g * (2^d)" with actual values a, b, g, d
#####   Info:     uses values a, b, g, d in registers $a0, $a1, $a2, and $a3 respectively
#####             and prints "gcd(a,b) = g * (2^d)
###################################################################################  
          
print:
      #set up stack
      addi $sp, $sp, -4     #allocate stack frame of 4 bytes
      sw   $ra, 0($sp)      #save return address
      #store arguements
      add   $t0, $a0, $0   #a
      add   $t1, $a1, $0   #b
      add   $t2, $a2, $0   #g
      add   $t3, $a3, $0   #d
      #print gcd(a, b) = g *(2^d)
      la    $a0, gcd        #load a "gcd(" as an argument for printing
      li    $v0, 4          #ask for print service
      syscall               #prints a "gcd("
      
      add   $a0, $t0, $0    #load a to a0
      li    $v0, 1          #ask integer print service
      syscall               #prints a
      
      la    $a0, comma     #load "," to a0
      li    $v0, 4         #ask string print service
      syscall              #print ","
      
      add   $a0, $t1, $0   #load b to a0
      li    $v0, 1         #ask integer print service
      syscall              #print b
      
      la    $a0, equals    #load ") = " to a0
      li    $v0, 4         #ask string print service
      syscall              #print ") = "
      
      add   $a0, $t2, $0   #load g to a0
      li    $v0, 1         #ask integer print service
      syscall              #print g
      
      la    $a0, times2    #load " *(2^" to a0
      li    $v0, 4         #ask string print service
      syscall              #print " *(2^"
      
      add   $a0, $t3, $0   #load d into a0
      li    $v0, 1         #ask integer print service
      syscall              #print d
      
      la    $a0, endPar    #load ")" into a0
      li    $v0, 4         #ask string print service
      syscall   
                 
      #restore stack 
      lw   $ra, 0($sp)  #restore return address
      addi $sp, $sp, 4  #free stack frame
      #return to caller
      jr $ra            #return to caller 
      
exit:
