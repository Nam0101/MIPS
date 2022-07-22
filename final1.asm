# Author: Nguyen Van Nam - 20205106
# Create date: 13/07/2022
# Hanoi university of science and technology
.data
	Nhap: .asciiz "Nhap vao lenh hop ngu can kiem tra: "
	loiCuPhap: .asciiz "\nLoi cu phap!\n"
	loiRegister: .asciiz " sai khuon dang, ban can nhap vao mot thanh ghi!"
	loiNumber: .asciiz " sai khuon dang, ban can nhap vao mot hang so!"
	loiLabel: .asciiz " sai khuon dang, ban can nhap vao mot label"
	notFoundOpcode: .asciiz "Khong tim thay opcode: "
	loiKhuonDang: .asciiz "\nLoi khuon dang!\n"
	ketThuc: .asciiz "\nLenh hop le!\n"
	opcode_hople: .asciiz "Opcode: "
	toanHangHopLe: .asciiz "Toan hang: "
	hople: .asciiz "hop le.\n"
	soChuKy: .asciiz "So chu ky cua lenh la: "
	# tin nhan voi nguoi dung
.data
	# vung nho space
	cmd: .space 100
	opcode: .space 10
	register: .space 20
	number: .space 15
	label: .space 30
.text
.globl main
main:	# nguoi dung nhap chuoi
	la $a0, Nhap
	jal PrintString
	li $v0, 8
	la $a0, cmd
	li $a1, 100
	syscall
	la $a1, opcode # luu cac ki tu doc duoc vao opcode
	move $s0,$a0
	move $s1,$a1
#--------------------------------------------------------------------------
# Doc opcode nhap tu nguoi dung: doc cac ki tu den khi ggap dau ' ' hoac doc het chuoi!
readOpcode:
	lb $t1, 0($a0) # doc tung ki tu cua cmd
	sb $t1, 0($a1)
	beq $t1, 32,readOpcodedone # gap ki tu ' ' ket thuc doc opcode
	beq $t1, 0, readOpcodedone  # ket thuc chuoi cmd
	addi $a0,$a0,1
	addi $a1,$a1,1
	j readOpcode
readOpcodedone : # khoi tao cac bien ban dau:
		#a0 chua dia chi cmd
		#a1 chua dia chi opcode
		#t7 la con tro thu vien
	move $a0,$s0
	move $a1,$s1
	li $t7,-10
	la $a2, opcode_lib
#----------------------------------------------------------------------------
# ket thuc doc opcode
#----------------------------------------------------------------------------
#xy ly opcode:
xuLyOpcode:
	add $t1,$zero,$zero # init i=0
	add $t2,$zero,$zero # init j=0
	addi $t7,$t7,10 #
	add $t1,$t1,$t7 # cong buoc nhay = 10 vi moi opcode mau cach nhau 10 char
	compare:
		add $t3, $a2, $t1 # con tro thu vien
		lb $s0, 0($t3)
		beq $s0, 0, error # xet het thu vien ma khong tim thay opcode trung -> khong co opcode, in va ket thuc
		beq $s0, 45, checkOpcode # gap ki tu '-' kiem tra xem opcode nhap vao co giong khong
		add $t4, $a1, $t2 # con tro opcode , load byte opcode
		lb $s1, 0($t4)
		bne $s0,$s1,xuLyOpcode # so sanh 2 ki tu. dung thi so sanh tiep, sai thi nhay den phan tu chua khuon danh lenh tiep theo.
		addi $t1,$t1,1 # i=i+1
		addi $t2,$t2,1 # j=j+1
		j compare
	checkOpcode:
		add $t4, $a1, $t2 # lay byte cuoi cua opcode
		lb $s1, 0($t4)
		bne $s1, 32, notAopcode # neu ki tu tiep theo khong phai ' ' => lenh khong hop le.
	opcodeHople:
		add $t9,$t9,$t2 # t9 = luu vi tri de xu ly register trong cmd
		la $a0,opcode_hople  # opcode hop le
		jal PrintString
		la $a0, opcode
		jal PrintString
		la $a0, hople
		jal PrintString
		j readToanHang1
	
	notAopcode: # neu ki tu tiep theo khong phai '\n' => lenh khong hop le. chi co doan dau giong.
		bne $s1, 10, error
		
#----------------------------------------------------------------------------
# ket thuc xy ly opcode
#----------------------------------------------------------------------------
.data
	# thu vien opcode :
			# moi opcode dai toi da 5 byte
			# 4 so tiep theo lan luot la:
				# kieu toan hang 1
				# kieu toan hang 2
				# kieu toan hang 3
				# so chu ky lenh
			# voi quy uoc nhu sau:
				# 0 : khong co
				# 1 : thanh ghi
				# 2 : hang so
				# 3 : label
			# vi du: add**1111:
				#opcode: add
				# toan hang 1: thanh ghi
				# toan hang 2: thanh ghi
				# toan hang 3: thanh ghi
				# so chu ki : 1
	opcode_lib: .asciiz "or---1111;xor--1111;lui--1201;jr---1001;jal--3002;addi-1121;add--1111;sub--1111;ori--1121;and--1111;beq--1132;bne--1132;j----3002;nop--0001;"
	# thu vien ki tu char: nhung ki tu cho phep trong label
	char: .asciiz "qwertyuiopasdfghjklmnbvcxzQWERTYUIOPASDFGHJKLZXCVBNM_"
	# thanh ghi
	registers_lib: .asciiz "$zero $at   $v0   $v1   $a0   $a1   $a2   $a3   $t0   $t1   $t2   $t3   $t4   $t5   $t6   $t7   $s0   $s1   $s2   $s3   $s4   $s5   $s6   $s7   $t8   $t9   $k0   $s6   $gp   $sp   $fp   $ra   $0    $1    $2    $3    $4    $5    $7    $8    $9    $10   $11   $12   $13   $14   $15   $16   $17   $18   $19   $20   $21   $22   $21   $22   $23   $24   $25   $26   $27   $28   $29   $30   $31   "
#----------------------------------------------------------------------------
.text
#----------------------------------------------------------------------------
# Xy ly cac toan hang
#----------------------------------------------------------------------------
# kiem tra toan hang 1
readToanHang1:
	# xac dinh kieu toan hang trong opcode_lib
	# t7 dang chua vi tri khuon dang lenh trong opcode_lib
	add $t1,$zero,$zero
	addi $t7, $t7, 5 # chuyen den vi tri toan hang 1 trong opcode_lib
	add $t1, $a2, $t7 # a2 chua dia chi opcode_lib
	lb $s0, 0($t1)
	li $t8, 49 # thanh ghi = '1'
	beq $s0, $t8, checkRegister
	li $t8, 50 # hang so nguyen = '2'
	beq $s0, $t8, checkConst
	li $t8, 51 # dinh danh = '3'
	beq $s0, $t8, checkLabel
	li $t8, 48 # khong co toan hang = '0'
	beq $s0, $t8, checkNT
	j end
#<--check register Register 2-->
readToanHang2:
	# xac dinh kieu toan hang trong opcode_lib
	# t7 dang chua vi tri khuon dang lenh trong opcode_lib
	li $t1, 0
	la $a2, opcode_lib
	addi $t7, $t7, 1 # chuyen den vi tri toan hang 2 trong opcode_lib
	add $t1, $a2, $t7 # a2 chua dia chi opcode_lib
	lb $s0, 0($t1)
	li $t8, 49 # thanh ghi = '1'
	beq $s0, $t8, checkRegister
	li $t8, 50 # hang so nguyen = '2'
	beq $s0, $t8, checkConst
	li $t8, 51 # dinh danh = '3'
	beq $s0, $t8, checkLabel
	li $t8, 48 # khong co toan hang = '0'
	beq $s0, $t8, checkNT
	j end
#<!--ket thuc check register Register 2-->

#<--check register Register 3-->
readToanHang3:
	# xac dinh kieu toan hang trong opcode_lib
	# t7 dang chua vi tri khuon dang lenh trong opcode_lib
	li $t1, 0
	la $a2, opcode_lib
	addi $t7, $t7, 1 # chuyen den vi tri toan hang 3 trong opcode_lib
	add $t1, $a2, $t7 # a2 chua dia chi opcode_lib
	lb $s0, 0($t1)
	li $t8, 49 # thanh ghi = '1'
	beq $s0, $t8, checkRegister
	li $t8, 50 # hang so nguyen = '2'
	beq $s0, $t8, checkConst
	li $t8, 51 # dinh danh = '3'
	beq $s0, $t8, checkLabel
	li $t8, 48 # khong co toan hang = '0'
	beq $s0, $t8, checkNT
	j end
#------------------------------------------------------------------------
# Key thuc kiem tra cac toan hang
#------------------------------------------------------------------------

# kiem tra thanh ghi xem co hop le khong
checkRegister:
	la $a0, cmd
	la $a1, register # luu ten thanh ghi vao register de so sanh
	li $t1, 0 #i =0
	li $t2, -1 # j =-1
	addi $t1, $t9, 0
	readRegister:
		addi $t1, $t1, 1 
		addi $t2, $t2, 1 
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang tiep theo trong cmd
		beq $s0, 44, readRegisterDone #ket thuc doc khi gap ki tu ','
		beq $s0,0, readRegisterDone # hoac ki tu ket thuc
		sb $s0, 0($t4)
		j readRegister
	
	readRegisterDone:
		sb $s0, 0($t4) # luu them ',' vao de so sanh!
		li $t1, -1 # i
		li $t2, -1 # j
		li $t4, 0
		li $t5, 0
		add $t2, $t2, $s6
		la $a1, register # dia chi register doc duoc
		la $a2, registers_lib # thu vien register
		j compareRegister
#---------------------------------------------------------------------------------
#ket thuc doc register
#----------------------------------------------------------------------------------
#so sanh register
compareRegister:
	addi $t1,$t1,1 # init i=1
	addi $t2,$t2,1# init j=1
	add $t4, $a1, $t1 # doc ki tu thu i cua register
	lb $s0, 0($t4)
	beq $s0, 0, end # doc het , gap ki tu rong thi hop le
	add $t5, $a2, $t2
	lb $s1, 0($t5)# doc ki tu thi j cua thu vien register
	beq $s1, 0, notAregister # doc het ma khong trung -> sai
	beq $s1, 32, length
	bne $s0,$s1, nextRegister
	j compareRegister
	
	length:
		beq $s0, 44, endCheckRegister # dau ,
		beq $s0, 10, endCheckRegister # dau '\n'
		j notAregister 
	nextRegister:
		addi $s6,$s6,6 # chuyen sang thanh ghi tiep theo
		j readRegisterDone
	endCheckRegister:
		la $a0, toanHangHopLe # Thanh ghi hop le
		jal PrintString
		la $a0, register
		jal PrintString
		la $a0, hople
		jal PrintString
		addi $v1, $v1, 1 # dem so toan hang da doc.
		li $s6, 0 # reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		beq $v1, 3, readChuKy
		j end
	notAregister:
		j notFoundRegister
#-------------------------------------------------------------
#doc xong register
#------------------------------------------------------------
#kiem tra hang so nguyen
checkConst: # kiem tra co phai hang so nguyen hay ko
	la $a0, cmd
	la $a1, number # luu day chu so vao number de so sanh tung chu so co thuoc vao numberGroup hay khong.
	li $t1, 0# i=0
	li $t2, -1#j=-1
	addi $t1, $t9, 0
	readConst:
		# tuong tu kiem tra register
		addi $t1, $t1, 1 
		addi $t2, $t2, 1 
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang tiep theo trong cmd
		beq $s0, 44, readConstDone # gap dau ','
		beq $s0, 0, readConstDone # gap ki tu ket thuc
		sb $s0, 0($t4)
		j readConst
	readConstDone:
		sb $s0, 0($t4) # luu them ',' vao de so sanh
		li $t1, -1 # i
		li $t4, 0
		la $a1, number
		j compareConst
compareConst:
	addi $t1, $t1, 1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, end
	beq $s0, 45, compareConst # bo dau '-'
	beq $s0, 10, endCheckConst # gap '\n'
	beq $s0, 44, endCheckConst # gap dau ','
	li $t2, 48
	li $t3, 57 # so can nho hon '9' va lon hon '0'
	slt $t5, $s0, $t2
	bne $t5, $zero, notAnumber
	slt $t5, $t3, $s0
	bne $t5, $zero, notAnumber
	j compareConst

	endCheckConst:# hop le
		la $a0, toanHangHopLe
		jal PrintString
		
		la $a0, number
		jal PrintString
		
		la $a0, hople
		jal PrintString
		addi $v1, $v1, 1 # dem so toan hang da doc.
		li $s6, 0 # reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		beq $v1, 3, readChuKy
		j end
	notAnumber:
		j notFoundNumber
#-------------------------------------------------------------
#doc xong hang so
#------------------------------------------------------------
#kiem tra label 
# tuongg tu kiem tra register
checkLabel:
	la $a0, cmd
	la $a1, label # luu ten thanh ghi vao label de so sanh
	li $t1, 0#i
	li $t2, -1#j
	addi $t1, $t9, 0
	readLabel:
		addi $t1, $t1, 1 
		addi $t2, $t2, 1 
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang tiep theo trong cmd
		beq $s0, 44, readLabelDone # gap dau ','
		beq $s0, 0, readLabelDone # gap ki tu trong
		sb $s0, 0($t4)
		j readLabel
	readLabelDone:
		sb $s0, 0($t4) # luu them ',' vao de so sanh
		loopChar:
		li $t1, -1 # i
		li $t2, -1 # j
		li $t4, 0
		li $t5, 0
		add $t1, $t1, $s6
		la $a1, label
		la $a2, char
		j compareLabel
compareLabel:
	addi $t1,$t1,1 # i=i+1
	add $t4, $a1, $t1# lay ki tu thu i trong label
	lb $s0, 0($t4)
	beq $s0, 0, end # gap ki tu rong ->> hople
	beq $s0, 10, endCompareLabel #gap dau '\n'
	beq $s0, 44, endCompareLabel # gap dau ',' -> hop le
	looping:
	addi $t2,$t2,1
	add $t5, $a2, $t2
	lb $s1, 0($t5)
	beq $s1, 0, notAlabel
	beq $s0, $s1, nextChar # so sanh ki tu tiep theo trong label
	j looping # tiep tuc so sanh ki tu tiep theo trong char
	
	nextChar:
		addi $s6,$s6,1 # ki tu tiep theo
		j loopChar
		
	endCompareLabel:
		la $a0, toanHangHopLe # label hop le
		jal PrintString
		
		la $a0, label
		jal PrintString
		
		la $a0, hople
		jal PrintString
		addi $v1, $v1, 1 # dem so toan hang da doc.
		li $s6, 0 # reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		beq $v1, 3, readChuKy
		j end
	notAlabel:
		j notFoundLabel
#-------------------------------------------------------------
#doc xong label
#------------------------------------------------------------
# kiem tra xem khong co gi khong

checkNT:
	la $a0, cmd # comand
	li $t1, 0# i
	li $t2, 0# j
	addi $t1, $t9, 0# nhay den vi tri can doc
	add $t2, $a0, $t1
	lb $s0, 0($t2)
	addi $v1, $v1, 1 # dem so toan hang da doc.
	li $s6, 0 # reset buoc nhay
	beq $v1, 1, readToanHang2
	beq $v1, 2, readToanHang3
	beq $v1, 3, readChuKy
#--------------------------------------------------------------	
#_--------------------------------------------------------------
# hoan thanh doc cac truongg hop! 
#Doc chu ki
#-------------------------------------------------------------------
readChuKy:
	# t7 dang chua vi tri khuon dang lenh trong opcode_lib
	li $t1, 0
	la $a2, opcode_lib
	addi $t7, $t7, 1 # chuyen den vi tri chu ki trong opcode_lib
	add $t1, $a2, $t7 # a2 chua dia chi opcode_lib
	lb $s0, 0($t1)
	addi $s0,$s0,-48 # chuyen tu char -> int
	la $a0, soChuKy # in ra chu ki
	jal PrintString
	li $v0,1
	li $a0,0
	add $a0,$s0,$zero
	syscall
	j end


notFoundLabel:# sai khuon dang label, in ra label sai, thong bao va thoat
	la $a0,toanHangHopLe
	jal PrintString
	la $a0,label
	jal PrintString
	la $a0,loiLabel
	jal PrintString
	j Exit
notFoundNumber: # sai khuon dang number, in ra number sai, thong bao va thoat
	la $a0,toanHangHopLe
	jal PrintString
	la $a0,number
	jal PrintString
	la $a0,loiNumber
	jal PrintString
	j Exit
notFoundRegister: # sai khuon dang register, in ra register sai, thong bao va thoat
	la $a0,toanHangHopLe
	jal PrintString
	la $a0,register
	jal PrintString
	la $a0,loiRegister
	jal PrintString
	j Exit
error: # khong tim thay opcode, in ra opcode sai va thoat
	la $a0,notFoundOpcode
	jal PrintString
	la $a0,opcode
	jal PrintString
	la $a0, loiCuPhap
	jal PrintString
	j Exit 
end: # lenh hop ngu dung, in ra va thoat
	la $a0, ketThuc
	jal PrintString
	j Exit
TheEnd:
.include "utils.asm"
