From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 01/26] drivers: isdn: Rectify typing error in xdi_msg.h
Date: Fri, 7 Feb 2014 17:48:07 +0530
Message-ID: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rectify typing error while including the guard for the header
file xdi_msg.h so that proper guard is wrapped around the file
to prevent it from being included more than once.

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/xdi_msg.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/xdi_msg.h b/drivers/isdn/hardware/eicon/xdi_msg.h
index 58368f7..2498c34 100644
--- a/drivers/isdn/hardware/eicon/xdi_msg.h
+++ b/drivers/isdn/hardware/eicon/xdi_msg.h
@@ -1,6 +1,6 @@
 /* $Id: xdi_msg.h,v 1.1.2.2 2001/02/16 08:40:36 armin Exp $ */
 
-#ifndef __DIVA_XDI_UM_CFG_MESSSGE_H__
+#ifndef __DIVA_XDI_UM_CFG_MESSAGE_H__
 #define __DIVA_XDI_UM_CFG_MESSAGE_H__
 
 /*
-- 
1.7.9.5
