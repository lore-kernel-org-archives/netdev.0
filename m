From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH firmware 3/3] rtl_nic: update firmware for RTL8411
Date: Tue, 27 Mar 2012 17:21:15 +0800
Message-ID: <1332840075-5991-3-git-send-email-hayeswang@realtek.com>
References: <1332840075-5991-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<kernel-team@fedoraproject.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332840075-5991-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated firmware with stability fixes.
Version: 0.0.2

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE               |    2 +-
 rtl_nic/rtl8411-1.fw |  Bin 1584 -> 1840 bytes
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHENCE b/WHENCE
index 1235477..989cd08 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1711,7 +1711,7 @@ File: rtl_nic/rtl8168f-2.fw
 Version: 0.0.4
 
 File: rtl_nic/rtl8411-1.fw
-Version: 0.0.1
+Version: 0.0.2
 
 File: rtl_nic/rtl8402-1.fw
 Version: 0.0.1
diff --git a/rtl_nic/rtl8411-1.fw b/rtl_nic/rtl8411-1.fw
index d9aaad151004e8853560918509f91d2329ec8f07..1bd9e7cdd5605e34e0322c0df185c53e46d6a34b 100644
GIT binary patch
delta 405
zcmXYtO-q776oucJ?9hivQL8Lai)fS1jAkl?5ZJ09YS$v6ZP6lHv`D%N6%>8Y+d6Qs
zqUgTgQ1k=LTC{RqkkFmpF5I~fcMgX+Q}@>cIfv`;Xg`(EdO_z^R7Fil#bahErj5O`
zwZYvIj<f7+t|g61<&Dxt#f=W>WG0c!EH-jkF+>t1A3%Ykdn2~QtJ@LTu^K3x0f}c&
z>51<fu92&!*H@rW71W&oS#CR^?MqPKF=+4+1Zy=9Y7odU|MWm#KGuDMimacjFi(0M
zw#+_f*3)vp;~C2XpbOs5GS{qUiaUrs`sjjuQ}E_A3p=3q6HuYe%>Bl~G|wnMvKj=9
zq`eFgo8i;T6k)^KD5x^*8H2Ohom>aqM?gX5-ne@pjVQQfsl;9LMV<?kcwgCV?)X-O
OXu0M7TmRoD{~y1?qj=f?

delta 156
zcmdnMw}Ho%0SJmpax6>?4RsCU4fG833>6Fw^o`8)4GlqZAP@k=<%|pr`V2unW<~}U
z@kR!Qh6a{~CJIIdRz@aP#v5Jj8Mzpl*czBB*&3!aOzvY0W{jHrh|ylqgsnl*imie1
zB3nb#exSVhWFscG$vMm#jLeg#G8-_8Z9c}_#>mzP)Vt=z<{(xlMn<d2Q`!0f{Olzc

-- 
1.7.7.6
