From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 11/15]drivers:media:video:cx18:cx23418.h Typo change diable to disable.
Date: Thu, 30 Dec 2010 15:08:00 -0800
Message-ID: <1293750484-1161-11-git-send-email-justinmattock@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-4-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-5-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-6-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-7-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-8-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-9-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-10-git-send-email-justinmattock@gmail.com>
Cc: linux-m68k@lists.linux-m68k.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ivtv-devel@ivtvdriver.org,
	linux-media@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:58873 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab0L3XIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 18:08:43 -0500
In-Reply-To: <1293750484-1161-10-git-send-email-justinmattock@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The below patch fixes a typo "diable" to "disable". Please let me know if this 
is correct or not.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/media/video/cx18/cx23418.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/media/video/cx18/cx23418.h b/drivers/media/video/cx18/cx23418.h
index 2c00980..7e40035 100644
--- a/drivers/media/video/cx18/cx23418.h
+++ b/drivers/media/video/cx18/cx23418.h
@@ -177,7 +177,7 @@
    IN[0] - Task handle.
    IN[1] - luma type: 0 = disable, 1 = 1D horizontal only, 2 = 1D vertical only,
 		      3 = 2D H/V separable, 4 = 2D symmetric non-separable
-   IN[2] - chroma type: 0 - diable, 1 = 1D horizontal
+   IN[2] - chroma type: 0 - disable, 1 = 1D horizontal
    ReturnCode - One of the ERR_CAPTURE_... */
 #define CX18_CPU_SET_SPATIAL_FILTER_TYPE     	(CPU_CMD_MASK_CAPTURE | 0x000C)
 
-- 
1.6.5.2.180.gc5b3e

