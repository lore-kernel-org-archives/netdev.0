From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH firmware] rtl_nic: add firmware for RTL8168H and RTL8107E
Date: Fri, 12 Sep 2014 14:54:23 +0800
Message-ID: <1394712342-15778-41-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<hau@realtek.com>, <ivecera@redhat.com>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ile: rtl_nic/rtl8168h-1.fw
Version: 0.0.1

=46ile: rtl_nic/rtl8168h-2.fw
Version: 0.0.1

=46ile: rtl_nic/rtl8107e-1.fw
Version: 0.0.1

=46ile: rtl_nic/rtl8107e-2.fw
Version: 0.0.1
Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |  12 ++++++++++++
 rtl_nic/rtl8107e-1.fw | Bin 0 -> 2496 bytes
 rtl_nic/rtl8107e-2.fw | Bin 0 -> 2464 bytes
 rtl_nic/rtl8168h-1.fw | Bin 0 -> 2496 bytes
 rtl_nic/rtl8168h-2.fw | Bin 0 -> 2464 bytes
 5 files changed, 12 insertions(+)
 create mode 100644 rtl_nic/rtl8107e-1.fw
 create mode 100644 rtl_nic/rtl8107e-2.fw
 create mode 100644 rtl_nic/rtl8168h-1.fw
 create mode 100644 rtl_nic/rtl8168h-2.fw

diff --git a/WHENCE b/WHENCE
index 26cabf4..3ffc68e 100644
--- a/WHENCE
+++ b/WHENCE
@@ -2149,6 +2149,18 @@ Version: 0.0.1
 File: rtl_nic/rtl8168g-3.fw
 Version: 0.0.1
=20
+File: rtl_nic/rtl8168h-1.fw
+Version: 0.0.1
+
+File: rtl_nic/rtl8168h-2.fw
+Version: 0.0.1
+
+File: rtl_nic/rtl8107e-1.fw
+Version: 0.0.1
+
+File: rtl_nic/rtl8107e-2.fw
+Version: 0.0.1
+
 Licence:
  * Copyright =C2=A9 2011-2013, Realtek Semiconductor Corporation
  *
diff --git a/rtl_nic/rtl8107e-1.fw b/rtl_nic/rtl8107e-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..5ac3d62bcd6adb9a28bc84d=
cccbccd99a0dab290
GIT binary patch
literal 2496
zcmY+`aY$8J9tZH#8`lw6?5({q$7vb~2?^JE&%|{l<k3V(NQ6j4L^+P@NJxlCL_~YW
ziHK+%iHL{@S0o~$iHMMB#F5sG2x%iCB;p|w5z$0MM1;E^o!MpPzW3qxJ?Fl2&b{~i
z@ooqq^!4{NWYT~6+n+PL(lzOtOhx*ypJ!@6&(t}$aJ18w2;uLcwWWS-eeJH^FZ;jh
z-c_5<)TNE9`Ks&dicDSO+Dv0+ZTN1qa$(G`WoStV*~z7!#SjW8q=3D;gYl#rq{eh@+~
z`dvXT#HG1J{8KJ3F3aV|k8%ZZd9E;ioGXf-<ci~m|1$2=3Dk~sTaD*n`58WaC4i{Z!e
zI2TsLiQG!<3hh;~G*Kz9maELaMy{4?<aA6-)y6PhC)djja-+OXZj!U|dU=3DDqQEp}v
zEo^2Bt+cU~ZER-;J87qbPP*u3H$Cj3mp=3DO0%RcsVfP+K^IK*L&aFk;VGQ@FCaFSD;
z<_u>UW`t4Bah?lY<Pw*;!d0#@#&vEm&IFU(WQtqd<_^=3D`<sSEWz(Zzu#A9;IGRG61
z@{H%a;3cnk%^TkGj`z$Hz6l{g9{ChdND;*(DIrBEWt6jml~k~bN>)?F8mg%wO)YiQ
z(?BEZXd=3DscHn5RqHqpXnw$Mr&TiM2TcCeFnI_RW}Zg$hd9(w7cpS|p3KL<ESWPn2)
z<_JeQ#vnr+=3DL9D?#c9rPmSIL1<s9d^z(p=3D`nJZl78e?4N2IEXH$xWuX#cl2|&0X$s
zp9ef-hDSUm$1HO^;VI8}&I?}hir2j1E$?{GJYm58lSe)U6jDSnNlHjjN*U#>U?ml-
zqLS5Av4(1DNK;E4^)%4PI-1C`o(*iInN75?nJu)^##XkmogM6?oenzbqMP0Hu!mmy
z=3Dw~nc*v|nD5*gqShdIJgjxop($2q}CPH~zuoMo61MmfiME^v`cT;>W_xyBgRxxqLS
zOmdScZgHDCOmmle+~)xgnc)$S$uY|uPk72Rp7Vm2yy7))c*{H9Gf()|{*y;O1r$<5
zF-b~DQA!!*tY9S-tfG?DRI!F?YDiN{9rZNO$U2(HvYriWq?t{$u$e8i(#BS{v7H_4
zq@4~r>7tw6^st9s`simb``FI`4iXvQ5QjO!QI0Xl5XU*eNltN^Gn{3Z5k@)3c`k5~
zOI+p(SGmR**SWzs6HIcGDQ<C_J4|zzd)(&%51HW+kI6C198Y-4GoJH;m%QRNZ+Oc)
z-ZTI0;=3D4l3kF(wvl8M6jK`2}JPsk4Zap4^z>9hEqh>PveyTpPEU0EBS4T<4S4=3D98`
zq`xTqELO#3F?6J2&DgTIB&6a(UxhrBNX3$2=3Dk%r2yy{d;{?<q;F8PPP=3D~V2^rDAre
z_78lYicMwu2jy?nfmEESO2zVD=3DgL=3D?n=3D?=3DSNKL5A)S&*`xP`To)?T=3Dd5Pn(z=
m-|{C
e=3DKm8aLRdcW|LZpHfA{?J;<@BRc5z(z-SJ;Ub$cHG

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8107e-2.fw b/rtl_nic/rtl8107e-2.fw
new file mode 100644
index 0000000000000000000000000000000000000000..949ca670fa31242940caa9f=
2222c0e268274ae0c
GIT binary patch
literal 2464
zcmYk;aY$8J9tZH#8^>`RF~{DR>$HtD5)!UGO&nJu-nb@ixDgT(5$QUPE3Jr#L`1|H
zCnBN=3DiHL{@35kd{A|fPOainn~A|fIpA|4_U5p6_7MA&|GnxXsNhu`<yd(S!d-Sfvg
zA%rk6*jrbX`sVw;RJW%pQ<YVvslTqQs$N-D<J#QO!9Nlqd>dL@YFE`(H?%jl{=3DIE&
zYkU7c2fyoSZ|eJguzl^?wUys>|EsjBrhZjbebqPNr_r*xz6(M~PcHl_hLA%pdE`?-
zAxVnjM<HaQ`*JcNF3cq2=3Db5ayD3cw($mGPuncVoNOkVsllOI3%Rlh$M#_6Au@#p5E
znE0hQhX0ntnXn{IWR_}|YA=3DgLi86V)TyFdoa)n$er($BNI)?EYxmK=3D|>*dw*8aXXD
z$c=3DK7+{`*!SkDGp*+?6k*vuBT(m^L(bkoB&dg-H|0S4L54tBDO-9(1i!(R5Wp936Z
zm_r=3Dq2uC@_aZWJ8Nk%!vY0hw#bDZY_7rDe3m$||?6HIcIDXwvy8{Fg;x4FYz?s1<7
zJS4+3Gd$ukPk72Rp7Vm2yy7))c*`u|hY%8EkxdS{<dIJSg(NAWm=3Dcz-lv0*a#&XJ8
zK?RkhsHTQm>ZoTmYe>^TBTY23juzIlfmSxs#wIqig{^eZNf+Jpu#H~&=3Dx2aIwzGqs
z>|!^OA@;DBeeCA|2N~uNhdIJgj&Yn5jBt`sPH~zuoaG$nxxhs(F~()CFwO*%TxE)D
zT;~Qixy5bnaF=3D`B=3DK&ANFwG2)c+3-?@{H%a;3cnk%^Th_OBk~LWRXn{x#W>g0fi(f
zqL>nvu#{4kQO0u0SwRJrq^PEbTI#50HET%IKqE~wvyK+lvw>DN(#9q>vxTj6&`B5F
z^stRy`sinXLAJAlo$O*aks<c5mwoK#00$Z75QjO!QI2t(6O3?@QBHB1Go0ld=3DefW|
zE-}Vst}xC7lU!wrYh33BH@U@a?r@iT+~)xg$uP|fk9f=3Dzp7M<6yx=3D9Tc+DH$GE4Z;
z`jbUAIpmT@J_Qt#q=3D;flSi(|DSw<PlDQ5*0RFa~a8fvMdp4F@&O#_WI(abtpSkDGp
z*+?6k*vuBT(m^L(bkoB&dg-H|0S4L54tBDO-9(1i!(R5Wp936Zm_r=3Dq2uC@_aZWJ8
zNk%!vY0hw#bDZY_7rDe3m$||?6HIcIDXwvy8{Fg;x4FYz?s1<7JS4+3Gd$ukPk72R
zp7Vm2yy7))c+2dM^LvGu9jEOV3KF^Tqfk8epO7B<Y;F%x;4}Z7i1Y2xzrciZr_vTa
z9TFp5UQh@hr~a1vRV<H-;)2d(tQ=3DEAGR~bVm4_3_SU9rCc*&SlvnrDD(+@28PcnX}
z_v>UVd4GSl`fgz|X1%Y8_cf^hUX+|4zrgr&bA|BR9KSvL;xPLzl!mZ);`e8poB#LU
Q^}qRR1rzD{e&LVf|B-EW9{>OV

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8168h-1.fw b/rtl_nic/rtl8168h-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..4bdd3825e3bdc9a15ddd87c=
199636bda4afb4169
GIT binary patch
literal 2496
zcmY+`aY$8J9tZH#8^;k>?2Wz5b=3DpQkLc+19<2tT{JlY5ei4cj1D8~^;LPSI&BI1k_
z5z)935fKrtNJK;%5h2ltBaIUg(nLf^#6u(^qK$}%2zNhPyX@ZgKK#Dt+;`5o_ntrA
z4IzZS{_gtfy85oKs&}WW(pA-E>A$S2u31-I>)gW8Mr$I3p3u@<_jO&(?%r?vzw6pv
zldi5!SEs+J`mXc)vg+D~uhR{G{wDl1TD~ymV;Nc!LS}O5mobDq@+qK@Bt@hsj-P~(
zjeeJx4RL8U5kJr7#AVssxICK|S7h_!AF~DVi)>;1>^I~7R1{}_O2uEAieuu}k{Et2
zjdNjToXD=3DyF4JBeixcJY8o9#!YvoG0N>0bbR80)ywQ`+YFE_~R<wiLpZ;&_2o8%@o
z)65pO(n2fS*v<}ivWqs_>7bJ?_Rviaz4Xz~UiPt{0~{nWz#$HEgrgi|kRgt9f|H!$
zG-o)=3DFe8j|j`LjLBA2+#6|QoPF|KoiaVD7LCR5zvHg}ljF88?410FKNBOa4wmN}mA
zlxIBW1uuEUYu@mdcf4nw@Iwd*a>yl*d<rNeNf9ZEDWQ~=3DtfGw7l(U8k)>26oX=3D<pY
zj(QqcPa_#Nu#rtPv6*JJu$2~C*~WHuu#;W1(M|`Qbg_qSdg!H(e)h7D{T$#RkpT{I
zm?IqJ7=3DsLPoD-bn6sI}ES%w*5lyjWt0vEZ&Wv+0QYm9N78;mo-BsZDj7Pq;>G<Uhj
zeID?T86NSNEVIn<gr_{?IWKt0D_--4x4h#$^MnEWPY$`{kxv1IBq<_AF(s6;l2w$k
znsU}q!CES*B25jo)KO0Z>uDsz1~#&ZCN|T|7PittE8E!44tBDOHrnZ+lP>nqO%J{F
z(a&D?v7ZARBr?Du4s(Q~9Al6nj&p*OoZ>WRILk02jB<|iT;L*?xXcx<a*Z*rbAxdv
znB*o?+~PKOnC33`xX%L~GQ%StlVz4Up74}sJm&>3dBtnq@RoPHXP)q*{U?W9^2n!v
zLXs4bqL>m&S;;EOSWP)=3Ds9-IXRFS5JTI#5$f%P<!VFMf4L=3D&57W(!+sp_OfHX9qjk
zMH}sO&`B42=3D%$BW`simb``FI`4iXvQ5QjO!QI0Xl5XU*eNltN^Gn{3Z5k@)3c`k5~
zOI+p(SGmR**SWzs6HIcGDQ<C_J4|zzd)(&%51HW+kI6F298Y-4GoJH;m%QRNZ+Oc)
z-ZTH>;=3D4l3jkDetl8OBINhn$PPsj}XVc{Jj>9hEqh>PveyTpPET^Spn35nqj4=3D99B
z(|^tXGFHT8F|?;*)!4GQB&6a(Uzt3VNX4RI=3Dk%r2oXS*8{;!c#T=3DI8))2Y~-O~uSo
z?SJsMRBSBKKPdm84y58tMJkqloGVvdVa^<NxtdUysX_hSxP`To)?T=3Dd5I(H`;l5Uc
e`G1A75LQh5_qvVy&prQh@mz8uvp6pN-|=3Drm*n1xU

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8168h-2.fw b/rtl_nic/rtl8168h-2.fw
new file mode 100644
index 0000000000000000000000000000000000000000..949bacc1614d6e101473661=
1bd371ef30a3e8daf
GIT binary patch
literal 2464
zcmYk;aY&Wt9tZHJGp}<_%-NYaZ)?&dB)oQXB2HQyoQVq;At4cw&N;6%5fO=3Dqi08V9
zh!zqN5fKs+5iKGjB)a02<{}~@A|fIVA`uZSA|fJeA6>ibJ?F#k`@HY_JkNXH=3Da2J*
z5W>J<Z(UVwUC+O&+f$XP%Bs@Tmn*BPS60=3DyHg|OJZ6buPLTgLy7q!(5?TxM9w5@4v
z@BeP_`=3D0iuz8?nL*Q{An`F;1lORH+?zo@EDRfnHP%jWtn2q8VW@Us{~4!Pu!PXUD_
zDT?ofkcsZg$%MEtlZYQ>vf`plcKkS#6BlQ4<0qNC_|Hs!eE&E7J}r#XKPTh=3Dnu}uM
z*WwudTM}o&k~ooBs$HtREEXlo<mGa?@mI(da;2P#iK*%s#%ttSxlXQ^SIMj8wA>&!
z%1v@JYiVH}>uF^JZER!{o7qAKopjMn4_oP_kA4OiWE<Pr!A^D&8Dckk*vmflbAVwE
za)`qm;V8#A&Il(M<s_##%^A*ej`LjLB4b?QGUH4z$rYx!$~CTYgPYvqHg~woJ?`^>
z4Aac;kVib`2~T;(b6)V0SG?v8vxNVIkRXd}a>yl*d<rNeNfE`Au!N<QvWzm8Q_c!1
zs3b)-HPli^J*!wvng$waqM5a{u#WY#vVk@>vWd-Xp@UAk=3D%$CQ^wLK^0}Qf_?d)JD
zyNC?2n?3AhANx7LFb6rrVUBQ=3DV;pCM6O3|_Q=3DH}uXF11tE^v`CE^(Q0CYa<3Q(Wa5
z*SWz>ZgHDC+~pqkc|e9~W_ZXW9`l5!JmWbpc*!eX^M+Z%ko6~vY;wpYk9-O!BuNp)
zl(2-Ql(LL6mQ&6ODySqyH8s>yM?I@pO_~N8X`-36w6Ko#w6cLVHnNG$Y@vfry6C2d
zt@P4IKLZT1jqU7UC%cFYv70^YWgq)Fz%U0n#9@wblw%xcgcFQ%l2e@K3}-pVc`k5~
zF)neLaVD7L3R7I=3D8rQkOO>S|UJKW_S_jy2uX=3DZrHBOddFr#$01FL=3Do-Uh{@o!cW$=
p
zEV9WVmpt+*ppYa*6jQ<ymQu<x%2-Z0E2yB76xGyFOC9yBVl`<RXrzf|*3!Z{*3-%c
z+Ste@HnW8eI_aXD9=3D6g;AN>q4$TqgKgPrUmGQ@87u$O)8=3DK#YT<Pe8B!cmTKoDohi
z%1KUfnlqf`9Ot>fMaH<qWyYCck}FJcm1|t*1~<9IZSHWFd)(&%8K#-xA&+>>6Q1&n
z=3De*!0uXxQHW`COBE5z(LZNE^E$c^uX;<^8X^w5WMdx!#``R_!WZ-@Q`CY(E!w(#kY
z80qqYLik7O>)g*`d0Z41bS7ivm>QCC?p&!noJhvPkwwN!#-y56k&GYw&4OQ&@$Y&+
zPsWmW_h+kb7bauYyP9}cgZks5<ox&r#-E!jgg@u_^Vt`N*|(uIgvAqoJ=3D@&;fBmlC
P=3DdTq^r04sE{~vz<lf`x)

literal 0
HcmV?d00001

--=20
1.9.3
