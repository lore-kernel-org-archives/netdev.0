From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/25) sk98: get rid of unused prototype
Date: Mon, 15 Nov 2004 15:23:16 -0800
Message-ID: <20041115152316.669737c2@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of unused prototype

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:24:36 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:24:36 -08:00
@@ -135,8 +135,6 @@
 #define SK_DBG_CHKMOD(pAC)	(SK_DEBUG_CHKMOD)
 #define SK_DBG_CHKCAT(pAC)	(SK_DEBUG_CHKCAT)
 
-extern void SkDbgPrintf(const char *format,...);
-
 #define SK_DBGMOD_DRV			0x00010000
 
 /**** possible driver debug categories ********************************/
