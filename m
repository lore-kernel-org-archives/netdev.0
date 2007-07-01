From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 3/4] [IrDA] kingsun-sir.c charset fix
Date: Mon, 02 Jul 2007 01:14:30 +0300
Message-ID: <20070701221705.948742675@sortiz.org>
References: <20070701221427.101308704@sortiz.org>
Content-Type: multipart/mixed; boundary="===============1840805965=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Alex=20Villac=C3=ADs=20Lasso?= <a_villacis-5itmuRygkZmgSpxsJD1C4w@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============1840805965==
Content-Disposition: inline; filename=kingsun-charset.patch

Cc: Alex Villacís Lasso <a_villacis-5itmuRygkZmgSpxsJD1C4w@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

---
 drivers/net/irda/kingsun-sir.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6-quilt/drivers/net/irda/kingsun-sir.c
===================================================================
--- net-2.6-quilt.orig/drivers/net/irda/kingsun-sir.c	2007-05-17 13:26:13.000000000 +0300
+++ net-2.6-quilt/drivers/net/irda/kingsun-sir.c	2007-05-22 09:48:21.000000000 +0300
@@ -4,7 +4,7 @@
 * Version:       0.1.1
 * Description:   Irda KingSun/DonShine USB Dongle
 * Status:        Experimental
-* Author:        Alex Villac�s Lasso <a_villacis-5itmuRygkZmgSpxsJD1C4w@public.gmane.org>
+* Author:        Alex Villacís Lasso <a_villacis-5itmuRygkZmgSpxsJD1C4w@public.gmane.org>
 *
 *  	Based on stir4200 and mcs7780 drivers, with (strange?) differences
 *
@@ -652,6 +652,6 @@
 }
 module_exit(kingsun_cleanup);
 
-MODULE_AUTHOR("Alex Villac�s Lasso <a_villacis-5itmuRygkZmgSpxsJD1C4w@public.gmane.org>");
+MODULE_AUTHOR("Alex Villacís Lasso <a_villacis-5itmuRygkZmgSpxsJD1C4w@public.gmane.org>");
 MODULE_DESCRIPTION("IrDA-USB Dongle Driver for KingSun/DonShine");
 MODULE_LICENSE("GPL");

-- 


--===============1840805965==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1840805965==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
irda-users mailing list
irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
http://lists.sourceforge.net/lists/listinfo/irda-users

--===============1840805965==--
