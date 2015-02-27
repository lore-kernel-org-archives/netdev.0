From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH firmware] rtl_nic: update firmware for RTL8168H and
 RTL8107E
Date: Fri, 27 Feb 2015 15:20:10 -0500
Message-ID: <20150227202009.GR30928@merlin.infradead.org>
References: <1394712342-15778-146-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-firmware@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394712342-15778-146-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 26, 2015 at 04:31:38PM +0800, Hayes Wang wrote:
> File: rtl_nic/rtl8168h-1.fw
> Version: 0.0.2
>=20
> File: rtl_nic/rtl8168h-2.fw
> Version: 0.0.2
>=20
> File: rtl_nic/rtl8107e-1.fw
> Version: 0.0.2
>=20
> File: rtl_nic/rtl8107e-2.fw
> Version: 0.0.2
>=20
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

applied, thanks very much.

regards, --Kyle

> ---
>  WHENCE                |   8 ++++----
>  rtl_nic/rtl8107e-1.fw | Bin 2496 -> 992 bytes
>  rtl_nic/rtl8107e-2.fw | Bin 2464 -> 976 bytes
>  rtl_nic/rtl8168h-1.fw | Bin 2496 -> 992 bytes
>  rtl_nic/rtl8168h-2.fw | Bin 2464 -> 976 bytes
>  5 files changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/WHENCE b/WHENCE
> index 609b93d..b79462f 100644
> --- a/WHENCE
> +++ b/WHENCE
> @@ -2188,16 +2188,16 @@ File: rtl_nic/rtl8168g-3.fw
>  Version: 0.0.1
> =20
>  File: rtl_nic/rtl8168h-1.fw
> -Version: 0.0.1
> +Version: 0.0.2
> =20
>  File: rtl_nic/rtl8168h-2.fw
> -Version: 0.0.1
> +Version: 0.0.2
> =20
>  File: rtl_nic/rtl8107e-1.fw
> -Version: 0.0.1
> +Version: 0.0.2
> =20
>  File: rtl_nic/rtl8107e-2.fw
> -Version: 0.0.1
> +Version: 0.0.2
> =20
>  Licence:
>   * Copyright =A9 2011-2013, Realtek Semiconductor Corporation
> diff --git a/rtl_nic/rtl8107e-1.fw b/rtl_nic/rtl8107e-1.fw
> index 5ac3d62bcd6adb9a28bc84dcccbccd99a0dab290..c071c2f0252b9254af810=
46c1f9a2996020b67a6 100644
> GIT binary patch
> delta 620
> zcmWlW4@gr{6vpq?a~s=3Dm{sAo;l(cD-ZEr8PL?R->_ChKmLPDDPCoG1IwN*s4&xnYy
> zNU4aLVKE{iWz>j>lwsR*M2IXilaSkpSP}6S5hFr69yoB$`F-c!`*D+%T;IYdf+2sC
> zOWe}4$>kFrqC;9MN>0h+bh(!yMSyaFQo{mALS4PSt`proK2dUslIU_fI*;{j9CWO<
> zxSQQg&60;*joFr$20I$;jOhT&8W=3Dc(g=3D<mH1?=3DKF$lQRF+=3DwtY<MiODGt#Kk=
AsJqe
> zck%|*s||1|4(dhfC9EqnqF(V(--MDxGwkWDNDgm9t+E}N@D99}cfzQ)U{3bJpzg*8
> zxfMEf59Z~45Y+w1h7aJQd=3DTY@HdLn%Av4^Ls`O!GhdZ!R>7;YJBbb$sVujj^8TmMb
> zf*(eu52fh<T@*w~JOsURit01a$In8moCBLU4_ytw5*OglUj!SugwLAGVA?BSLj!2d
> zUxUD}!|-hg+Vl;u@mpv!-G)AK2SOr>o3-~aZXW@^`v6vJB!<1-hsZ@AAs2j%G5HCW
> z3S(fVII0RyVVz1~Rq8o-^aU!dFG>4~v=3DhjMl9-k!Nt;4NN+F&h{)YHl;?u-uh-Zn<
> z!aOyHVrU+(y$dJ~e1Z^PBr}{Imji1b{{oxkEBb{z`pw^ATl@jWf09#`oc=3D=3D0{F{V=
-
> w$VCy1{iXRonlDk!`X}js8Fa`o1In~U2sLKZnM$FxlwrhNfz8kE8>%(`0WZl65C8xG
>=20
> literal 2496
> zcmY+`aY$8J9tZH#8`lw6?5({q$7vb~2?^JE&%|{l<k3V(NQ6j4L^+P@NJxlCL_~YW
> ziHK+%iHL{@S0o~$iHMMB#F5sG2x%iCB;p|w5z$0MM1;E^o!MpPzW3qxJ?Fl2&b{~i
> z@ooqq^!4{NWYT~6+n+PL(lzOtOhx*ypJ!@6&(t}$aJ18w2;uLcwWWS-eeJH^FZ;jh
> z-c_5<)TNE9`Ks&dicDSO+Dv0+ZTN1qa$(G`WoStV*~z7!#SjW8q=3D;gYl#rq{eh@+~
> z`dvXT#HG1J{8KJ3F3aV|k8%ZZd9E;ioGXf-<ci~m|1$2=3Dk~sTaD*n`58WaC4i{Z!e
> zI2TsLiQG!<3hh;~G*Kz9maELaMy{4?<aA6-)y6PhC)djja-+OXZj!U|dU=3DDqQEp}v
> zEo^2Bt+cU~ZER-;J87qbPP*u3H$Cj3mp=3DO0%RcsVfP+K^IK*L&aFk;VGQ@FCaFSD;
> z<_u>UW`t4Bah?lY<Pw*;!d0#@#&vEm&IFU(WQtqd<_^=3D`<sSEWz(Zzu#A9;IGRG61
> z@{H%a;3cnk%^TkGj`z$Hz6l{g9{ChdND;*(DIrBEWt6jml~k~bN>)?F8mg%wO)YiQ
> z(?BEZXd=3DscHn5RqHqpXnw$Mr&TiM2TcCeFnI_RW}Zg$hd9(w7cpS|p3KL<ESWPn2)
> z<_JeQ#vnr+=3DL9D?#c9rPmSIL1<s9d^z(p=3D`nJZl78e?4N2IEXH$xWuX#cl2|&0X$=
s
> zp9ef-hDSUm$1HO^;VI8}&I?}hir2j1E$?{GJYm58lSe)U6jDSnNlHjjN*U#>U?ml-
> zqLS5Av4(1DNK;E4^)%4PI-1C`o(*iInN75?nJu)^##XkmogM6?oenzbqMP0Hu!mmy
> z=3Dw~nc*v|nD5*gqShdIJgjxop($2q}CPH~zuoMo61MmfiME^v`cT;>W_xyBgRxxqLS
> zOmdScZgHDCOmmle+~)xgnc)$S$uY|uPk72Rp7Vm2yy7))c*{H9Gf()|{*y;O1r$<5
> zF-b~DQA!!*tY9S-tfG?DRI!F?YDiN{9rZNO$U2(HvYriWq?t{$u$e8i(#BS{v7H_4
> zq@4~r>7tw6^st9s`simb``FI`4iXvQ5QjO!QI0Xl5XU*eNltN^Gn{3Z5k@)3c`k5~
> zOI+p(SGmR**SWzs6HIcGDQ<C_J4|zzd)(&%51HW+kI6C198Y-4GoJH;m%QRNZ+Oc)
> z-ZTI0;=3D4l3kF(wvl8M6jK`2}JPsk4Zap4^z>9hEqh>PveyTpPEU0EBS4T<4S4=3D98=
`
> zq`xTqELO#3F?6J2&DgTIB&6a(UxhrBNX3$2=3Dk%r2yy{d;{?<q;F8PPP=3D~V2^rDAr=
e
> z_78lYicMwu2jy?nfmEESO2zVD=3DgL=3D?n=3D?=3DSNKL5A)S&*`xP`To)?T=3Dd5Pn=
(zm-|{C
> e=3DKm8aLRdcW|LZpHfA{?J;<@BRc5z(z-SJ;Ub$cHG
>=20
> diff --git a/rtl_nic/rtl8107e-2.fw b/rtl_nic/rtl8107e-2.fw
> index 949ca670fa31242940caa9f2222c0e268274ae0c..76fc0544f9fb06e7e9b57=
5a7fbb0ed00d10822b2 100644
> GIT binary patch
> delta 627
> zcmXw$eMnPb6vp3f*X=3DSd&JWO%L5Z72*}S_s8zUkjY&WDLA|#}lA7L>}Y^#W9&mtni
> z!r2E=3DTda_XNEtCAB4yZil?V|vvk1A3h#3)g5j7&D(;po;yyu+X!+GC_H&!-nY+@9B
> zexJ)BZSLAAdnLPMm)A;iz1&#uaQ=3Df7pq!;#V!em`9o^oJ<DFezNp?uG<Z#;CkM?W`
> z+p8;_Zl}xL;9^&Xtfc*a420Y2Y>XKI^BM>mgIVKHqVd?N8K7taPG}|sG!du5!}Y-i
> zwFb$+I?O8TQLER%q1vgJsFzWlYe22qNWBXM2{&x%El5VUqDtL{$-s8JQFg$jH(_4!
> zK+t#Lt<nsGz8ee5Uhw)p%mnu1opJyrxfWEU4`MRfit_X!%tYI;N^PgTok7egN3c@w
> z#<X$_e9i}x+JmBWFJ07!g18?>^(57&VT_*vr=3DA5HI|oB0z!K--%U%GBUBt%~m%zBo
> zV1xZ=3D&Rzwt4M12L1ed-JHhL2+g|}c#+y<YB;6~M5jM`$*?%apP5*)%F&jVy450UA6
> zgc0R2mUAOug>jVUp1?AZ!0OafXpv_qvpgs53(}4u<4<Br87FNDr74y8B=3DJ|oUlX4q
> zK23av_#DKEdF1^Ic<FhMeE$dV@kKJD(c>~;t)rh{HGf8k&mts#fpzgKnD&jF>g4o0
> zhQuEv{7EkIVC*-||ImDyY8D!&|79>B!vqv_Ch(OaY6^?MnTrt<OR?$NJ>l11jTsM$
>=20
> literal 2464
> zcmYk;aY$8J9tZH#8^>`RF~{DR>$HtD5)!UGO&nJu-nb@ixDgT(5$QUPE3Jr#L`1|H
> zCnBN=3DiHL{@35kd{A|fPOainn~A|fIpA|4_U5p6_7MA&|GnxXsNhu`<yd(S!d-Sfvg
> zA%rk6*jrbX`sVw;RJW%pQ<YVvslTqQs$N-D<J#QO!9Nlqd>dL@YFE`(H?%jl{=3DIE&
> zYkU7c2fyoSZ|eJguzl^?wUys>|EsjBrhZjbebqPNr_r*xz6(M~PcHl_hLA%pdE`?-
> zAxVnjM<HaQ`*JcNF3cq2=3Db5ayD3cw($mGPuncVoNOkVsllOI3%Rlh$M#_6Au@#p5E
> znE0hQhX0ntnXn{IWR_}|YA=3DgLi86V)TyFdoa)n$er($BNI)?EYxmK=3D|>*dw*8aXX=
D
> z$c=3DK7+{`*!SkDGp*+?6k*vuBT(m^L(bkoB&dg-H|0S4L54tBDO-9(1i!(R5Wp936Z
> zm_r=3Dq2uC@_aZWJ8Nk%!vY0hw#bDZY_7rDe3m$||?6HIcIDXwvy8{Fg;x4FYz?s1<7
> zJS4+3Gd$ukPk72Rp7Vm2yy7))c*`u|hY%8EkxdS{<dIJSg(NAWm=3Dcz-lv0*a#&XJ8
> zK?RkhsHTQm>ZoTmYe>^TBTY23juzIlfmSxs#wIqig{^eZNf+Jpu#H~&=3Dx2aIwzGqs
> z>|!^OA@;DBeeCA|2N~uNhdIJgj&Yn5jBt`sPH~zuoaG$nxxhs(F~()CFwO*%TxE)D
> zT;~Qixy5bnaF=3D`B=3DK&ANFwG2)c+3-?@{H%a;3cnk%^Th_OBk~LWRXn{x#W>g0fi(=
f
> zqL>nvu#{4kQO0u0SwRJrq^PEbTI#50HET%IKqE~wvyK+lvw>DN(#9q>vxTj6&`B5F
> z^stRy`sinXLAJAlo$O*aks<c5mwoK#00$Z75QjO!QI2t(6O3?@QBHB1Go0ld=3DefW|
> zE-}Vst}xC7lU!wrYh33BH@U@a?r@iT+~)xg$uP|fk9f=3Dzp7M<6yx=3D9Tc+DH$GE4Z=
;
> z`jbUAIpmT@J_Qt#q=3D;flSi(|DSw<PlDQ5*0RFa~a8fvMdp4F@&O#_WI(abtpSkDGp
> z*+?6k*vuBT(m^L(bkoB&dg-H|0S4L54tBDO-9(1i!(R5Wp936Zm_r=3Dq2uC@_aZWJ8
> zNk%!vY0hw#bDZY_7rDe3m$||?6HIcIDXwvy8{Fg;x4FYz?s1<7JS4+3Gd$ukPk72R
> zp7Vm2yy7))c+2dM^LvGu9jEOV3KF^Tqfk8epO7B<Y;F%x;4}Z7i1Y2xzrciZr_vTa
> z9TFp5UQh@hr~a1vRV<H-;)2d(tQ=3DEAGR~bVm4_3_SU9rCc*&SlvnrDD(+@28PcnX}
> z_v>UVd4GSl`fgz|X1%Y8_cf^hUX+|4zrgr&bA|BR9KSvL;xPLzl!mZ);`e8poB#LU
> Q^}qRR1rzD{e&LVf|B-EW9{>OV
>=20
> diff --git a/rtl_nic/rtl8168h-1.fw b/rtl_nic/rtl8168h-1.fw
> index 4bdd3825e3bdc9a15ddd87c199636bda4afb4169..296813ab073626b02b84a=
5297e91d6e35ba31b2c 100644
> GIT binary patch
> delta 620
> zcmWlW4@gr{6vnUXxs7c&|A3YaN}3vF+j|eU)`*G-+Y70P2nlJX7AwTY+A1R2XGBC;
> zq*O$?STQ1^WYma=3DlwsRbB1Fv0B;+<CW<<P2ghWWk0|(AIzwg|8KW@5$8=3D4qJDBR_=
d
> z+@8P&$uBxYhrC*powD00xt1VBkaCuCo&^twI|BZW6P-u=3DqAZEBD7hT%$GX?|IaXR-
> zUe_kCypdf^*q4_2+8SyZ(*xF3FmeVf*P)CH*va)!xDhA02@!6=3D>At7VXro$(bYv~w
> zE9+3NH9%4w)Qi;1SW{?3z3QgkgW{AIwb{)`$F`tG-G;Hqc6?BFz@#-{TJgcC?ZQW;
> z8G3CuW|X}Uw0)S2?8hhN0Llt2sLCG1SgaM5*+ZC&wPCs1PUm(;F{K>EGA)1!<v4^w
> z7ffn5O0q$^D1_o<7zXte)n{Nxo`p_52R3{j`f7lsE}$!a5iEWQUy3e+>8^nF_o6v}
> z4FbOo<9t7K*&AR(x6op~4MXY<gwz0T*4)ETZ5;gW1K4cQ1orqIA~)~|xzJ+_Do?Oj
> z7z8sXQCWBf+h__aGB3afUZTSGinOmuJB(a7jd5j!v>B9VRN`aA-x7aEe4O|M@k!!S
> zu#8S)Av}XOzF92veuj{oBQu;Hmji1Z`U<=3DC8+wF1dMw{zpZfvEf09#;oc=3D<>@|%Q=
z
> w$i)H}`%CkGG+(5e^^DN}GU$<GMwIGI5UMSxGnYVTEk)c?j;+t{8>@=3D`15teq5C8xG
>=20
> literal 2496
> zcmY+`aY$8J9tZH#8^;k>?2Wz5b=3DpQkLc+19<2tT{JlY5ei4cj1D8~^;LPSI&BI1k_
> z5z)935fKrtNJK;%5h2ltBaIUg(nLf^#6u(^qK$}%2zNhPyX@ZgKK#Dt+;`5o_ntrA
> z4IzZS{_gtfy85oKs&}WW(pA-E>A$S2u31-I>)gW8Mr$I3p3u@<_jO&(?%r?vzw6pv
> zldi5!SEs+J`mXc)vg+D~uhR{G{wDl1TD~ymV;Nc!LS}O5mobDq@+qK@Bt@hsj-P~(
> zjeeJx4RL8U5kJr7#AVssxICK|S7h_!AF~DVi)>;1>^I~7R1{}_O2uEAieuu}k{Et2
> zjdNjToXD=3DyF4JBeixcJY8o9#!YvoG0N>0bbR80)ywQ`+YFE_~R<wiLpZ;&_2o8%@o
> z)65pO(n2fS*v<}ivWqs_>7bJ?_Rviaz4Xz~UiPt{0~{nWz#$HEgrgi|kRgt9f|H!$
> zG-o)=3DFe8j|j`LjLBA2+#6|QoPF|KoiaVD7LCR5zvHg}ljF88?410FKNBOa4wmN}mA
> zlxIBW1uuEUYu@mdcf4nw@Iwd*a>yl*d<rNeNf9ZEDWQ~=3DtfGw7l(U8k)>26oX=3D<p=
Y
> zj(QqcPa_#Nu#rtPv6*JJu$2~C*~WHuu#;W1(M|`Qbg_qSdg!H(e)h7D{T$#RkpT{I
> zm?IqJ7=3DsLPoD-bn6sI}ES%w*5lyjWt0vEZ&Wv+0QYm9N78;mo-BsZDj7Pq;>G<Uhj
> zeID?T86NSNEVIn<gr_{?IWKt0D_--4x4h#$^MnEWPY$`{kxv1IBq<_AF(s6;l2w$k
> znsU}q!CES*B25jo)KO0Z>uDsz1~#&ZCN|T|7PittE8E!44tBDOHrnZ+lP>nqO%J{F
> z(a&D?v7ZARBr?Du4s(Q~9Al6nj&p*OoZ>WRILk02jB<|iT;L*?xXcx<a*Z*rbAxdv
> znB*o?+~PKOnC33`xX%L~GQ%StlVz4Up74}sJm&>3dBtnq@RoPHXP)q*{U?W9^2n!v
> zLXs4bqL>m&S;;EOSWP)=3Ds9-IXRFS5JTI#5$f%P<!VFMf4L=3D&57W(!+sp_OfHX9qj=
k
> zMH}sO&`B42=3D%$BW`simb``FI`4iXvQ5QjO!QI0Xl5XU*eNltN^Gn{3Z5k@)3c`k5~
> zOI+p(SGmR**SWzs6HIcGDQ<C_J4|zzd)(&%51HW+kI6F298Y-4GoJH;m%QRNZ+Oc)
> z-ZTH>;=3D4l3jkDetl8OBINhn$PPsj}XVc{Jj>9hEqh>PveyTpPET^Spn35nqj4=3D99=
B
> z(|^tXGFHT8F|?;*)!4GQB&6a(Uzt3VNX4RI=3Dk%r2oXS*8{;!c#T=3DI8))2Y~-O~uS=
o
> z?SJsMRBSBKKPdm84y58tMJkqloGVvdVa^<NxtdUysX_hSxP`To)?T=3Dd5I(H`;l5Uc
> e`G1A75LQh5_qvVy&prQh@mz8uvp6pN-|=3Drm*n1xU
>=20
> diff --git a/rtl_nic/rtl8168h-2.fw b/rtl_nic/rtl8168h-2.fw
> index 949bacc1614d6e1014736611bd371ef30a3e8daf..df92848abbd257c2375d0=
a5bc6164634d06855dd 100644
> GIT binary patch
> delta 627
> zcmXw$eMpm06o+qXZetGT2WZKl#IGou+i+qM6%pneQV|gnlBO0GVq#lGL_S7DgoWA%
> zQ5qH!5hWu=3DM5KthSBVhuD~ph~5n&OrMU+HHr$0JyxaXYb$GP{%?M<7omMMvrKx2uw
> zxTImduiE4GxP7ZVzCvGdq1XQpN+3BUIis2n2I?BB>yFhQs`mK29-qhSch??iTG#2$
> z&hVG|H<T9n)#bh%(f&U=3DI%^7Ym9l_y6*fcRG)$xzX0{s^G{eSm!%om}aI*7pVQZ0|
> z$53z$Q`%bcV+DA1xAY$AePqXr$k&UdFCigZN^WE$Lp__w(zh@c+{%o$4STGNS*;vf
> zYzJ?&3M{dm%xSwZ$M!H8+{;^SA1U!lG9vpK>!~6=3Da)8O68dm7FvbVmKY3(q}V+~Ab
> zM=3D{46vFlAFMVjTJ77{`MtojM5Phkz6#-yJ?4W7l42`YS!#)b2!-V1zKb`fQ|gz9Ri
> zV&MvAqXXOLE=3D-YYsDT?)Cf>vvzJ)p5&GoE14CMA=3D+`fm))!N6d^7}-)9}sPMNWb=3D=
o
> zrFcIoF+_U&39ivFD@UGUbU!1_^<1<sL_0_{FvPevEZPxLM|9z1!e0r0Eqq+~gz!n>
> z(>O+FSq#kaviu#3?e8&%=3DEaO5kBg$J20oJG{6w31fi}k%a^}CHjBnyJCQiT8=3DlCJ=
Q
> vpW<Q>rGCr&kIa{(R&B%bzX}UcWh2>S$DHXPFEI&|GnrmTDx0s~wf*`FbKeh&
>=20
> literal 2464
> zcmYk;aY&Wt9tZHJGp}<_%-NYaZ)?&dB)oQXB2HQyoQVq;At4cw&N;6%5fO=3Dqi08V9
> zh!zqN5fKs+5iKGjB)a02<{}~@A|fIVA`uZSA|fJeA6>ibJ?F#k`@HY_JkNXH=3Da2J*
> z5W>J<Z(UVwUC+O&+f$XP%Bs@Tmn*BPS60=3DyHg|OJZ6buPLTgLy7q!(5?TxM9w5@4v
> z@BeP_`=3D0iuz8?nL*Q{An`F;1lORH+?zo@EDRfnHP%jWtn2q8VW@Us{~4!Pu!PXUD_
> zDT?ofkcsZg$%MEtlZYQ>vf`plcKkS#6BlQ4<0qNC_|Hs!eE&E7J}r#XKPTh=3Dnu}uM
> z*WwudTM}o&k~ooBs$HtREEXlo<mGa?@mI(da;2P#iK*%s#%ttSxlXQ^SIMj8wA>&!
> z%1v@JYiVH}>uF^JZER!{o7qAKopjMn4_oP_kA4OiWE<Pr!A^D&8Dckk*vmflbAVwE
> za)`qm;V8#A&Il(M<s_##%^A*ej`LjLB4b?QGUH4z$rYx!$~CTYgPYvqHg~woJ?`^>
> z4Aac;kVib`2~T;(b6)V0SG?v8vxNVIkRXd}a>yl*d<rNeNfE`Au!N<QvWzm8Q_c!1
> zs3b)-HPli^J*!wvng$waqM5a{u#WY#vVk@>vWd-Xp@UAk=3D%$CQ^wLK^0}Qf_?d)JD
> zyNC?2n?3AhANx7LFb6rrVUBQ=3DV;pCM6O3|_Q=3DH}uXF11tE^v`CE^(Q0CYa<3Q(Wa=
5
> z*SWz>ZgHDC+~pqkc|e9~W_ZXW9`l5!JmWbpc*!eX^M+Z%ko6~vY;wpYk9-O!BuNp)
> zl(2-Ql(LL6mQ&6ODySqyH8s>yM?I@pO_~N8X`-36w6Ko#w6cLVHnNG$Y@vfry6C2d
> zt@P4IKLZT1jqU7UC%cFYv70^YWgq)Fz%U0n#9@wblw%xcgcFQ%l2e@K3}-pVc`k5~
> zF)neLaVD7L3R7I=3D8rQkOO>S|UJKW_S_jy2uX=3DZrHBOddFr#$01FL=3Do-Uh{@o!c=
W$p
> zEV9WVmpt+*ppYa*6jQ<ymQu<x%2-Z0E2yB76xGyFOC9yBVl`<RXrzf|*3!Z{*3-%c
> z+Ste@HnW8eI_aXD9=3D6g;AN>q4$TqgKgPrUmGQ@87u$O)8=3DK#YT<Pe8B!cmTKoDoh=
i
> z%1KUfnlqf`9Ot>fMaH<qWyYCck}FJcm1|t*1~<9IZSHWFd)(&%8K#-xA&+>>6Q1&n
> z=3De*!0uXxQHW`COBE5z(LZNE^E$c^uX;<^8X^w5WMdx!#``R_!WZ-@Q`CY(E!w(#kY
> z80qqYLik7O>)g*`d0Z41bS7ivm>QCC?p&!noJhvPkwwN!#-y56k&GYw&4OQ&@$Y&+
> zPsWmW_h+kb7bauYyP9}cgZks5<ox&r#-E!jgg@u_^Vt`N*|(uIgvAqoJ=3D@&;fBmlC
> P=3DdTq^r04sE{~vz<lf`x)
>=20
> --=20
> 2.1.0
>=20
>=20
