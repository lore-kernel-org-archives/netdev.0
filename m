From: Yannick Guerrini <yguerrini@tomshardware.fr>
Subject: [PATCH] qlcnic: Fix trivial typo in comment
Date: Fri, 27 Feb 2015 18:12:16 +0100
Message-ID: <1425057136-13988-1-git-send-email-yguerrini@tomshardware.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-GELinuxNICDev@qlogic.com>, <trivial@kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Yannick Guerrini <yguerrini@tomshardware.fr>
To: <shahed.shaikh@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change 'Firmare' to 'Firmware'

Signed-off-by: Yannick Guerrini <yguerrini@tomshardware.fr>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index fa43176..f221126 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -314,7 +314,7 @@ struct qlcnic_fdt {
 #define QLCNIC_BRDCFG_START	0x4000		/* board config */
 #define QLCNIC_BOOTLD_START	0x10000		/* bootld */
 #define QLCNIC_IMAGE_START	0x43000		/* compressed image */
-#define QLCNIC_USER_START	0x3E8000	/* Firmare info */
+#define QLCNIC_USER_START	0x3E8000	/* Firmware info */
 
 #define QLCNIC_FW_VERSION_OFFSET	(QLCNIC_USER_START+0x408)
 #define QLCNIC_FW_SIZE_OFFSET		(QLCNIC_USER_START+0x40c)
-- 
1.9.5.msysgit.0
