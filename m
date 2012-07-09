From: Hayes Wang <hayeswang@realtek.com>
Subject: =?	?q?=5BPATCH=20firmware=203/4=5D=20rtl=5Fnic=3A=20add=20new=20firmware=20for=20RTL8106E?=
Date: Mon, 9 Jul 2012 11:11:51 +0800
Message-ID: <1341803512-1309-3-git-send-email-hayeswang@realtek.com>
References: <1341803512-1309-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="\"\""
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341803512-1309-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ile: rtl_nic/rtl8106e-1.fw
Version: 0.0.1

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    3 +++
 rtl_nic/rtl8106e-1.fw |  Bin 0 -> 1856 bytes
 2 files changed, 3 insertions(+)
 create mode 100644 rtl_nic/rtl8106e-1.fw

diff --git a/WHENCE b/WHENCE
index c7a3e98..8f2b610 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1813,6 +1813,9 @@ Version: 0.0.3
 File: rtl_nic/rtl8402-1.fw
 Version: 0.0.1
=20
+File: rtl_nic/rtl8106e-1.fw
+Version: 0.0.1
+
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
  *
diff --git a/rtl_nic/rtl8106e-1.fw b/rtl_nic/rtl8106e-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..85694cb6bf5f0a180735639=
2497703a779b5148e
GIT binary patch
literal 1856
zcmZ{lYlxIp7{||CawkZ3{NN2d?SMi<kiIk6ZtjOz!(u_ZfSV}_Gv%%qTtXJ{lWtFC
zAmnxtFA!a(8Y+@B(#j}t>x&;G)KF7QP>}FL6lNbnrS12B-}AD=3DL<0}cdCz&C|MPz?
z=3DZtgCjcgfys1kJ#Jy5Ad^P~BdQq;Ymx@bYA%9(z3<m-%cXWa8^w+z>0TdPKuYSdkM
zur@fdaqG}XsnXLME$m&`<Hnlv<P+2zdDmr<&6{VNn=3D;4Tes5P^@aC3z>*zx-LHfOQ
zZA<ow%h7dYgSUs*qg^6h&v?6C^OpbA+sf7KJ?m{o<ZY0(VSno*Z<l`YHXZxv-*}t$
zrMFFIymj*3d4%<8Z&O)M`NCU9u~vd5y~bM+9PMSoUY<Q+k0O5|?^P1cbvWnX<+dXm
zy_JU0U`ld_hzqA)?DyBPhwnY$?LrLR_qF7xT#I129o{0=3DCG3y4oo6`D9`&{yyaF}_
z#SO8F^5^^1d2HDG#}a;qkIqy(`ADZebNQaT#@oI9leHF)tbC~X#Eag(Csy2>$GuhC
z?8G<5gzK@Ux5F2SOKjPfuy>=3D#bJQ?kjI;O7>A;Wr%g)$S&GTSn;Z|<xZ;CzK7FTu1
z?VZHe9DGYX?+SBZ>IHRwi@5PD@U3|`@FQ~qzcKU*^d|TYpc`<yAbk>C^l#?vV|<Sw
z;&_F4?YS31?u9zBUWPmKrP<gJd>Z6cUdI`DlEw;pzX}b{CUNrYiHCZ1$C5aW6mxLW
zFP<yvlKU#@W3f)J$fxUR>K$@6>ZjS&9r&5}>9=3DzKzZr{X0xab>PTV+7OI+1+UR&Ms
zvU>?1#Ty7dE%UCLrM-4fOy1@A{*puM-R-1j6M_F~-G|V#4(`?Z@U5QZ_7Eq`(TCLQ
zy7Tr5`d762cMW}QA2x0H@eIP@GH3Z$!+m)QyaQooS!eJWZJD=3Dim%RNBp89o_y7b}S
zLk(sv@pfWyQY-ECh5U6_G>fVJ;dT1^leeY#=3DXZO1q`};fkKPO6)$x5Byz*lSmcGm6
zrtcK9{T;ea+!R06pAcs;Z`S?bFAMKb1FS53vT*H3_7Eqvm(Ia6?Pmw;Kfs+p-VAoy
zlif_T-k`r<OL86~);V(Ne4iejrFP_I=3De!+7XFs4<#E<VUF}2=3D-%}vgvZ=3DjWXe23t=
d
z=3DC~8vQ^Zcs#yPv$#`kV`6dp}Dd=3D7_M)b${EP4v6yogr_-H@%x_FQ(yJCWhkm4bUTW
z>pQNR9&Yj$1&q>@|DB(7KK0+C`P6&z8TRpP*1i4t9hl^%|1p=3DHW0C&LwC49OflNUk

literal 0
HcmV?d00001

--=20
1.7.10.2
