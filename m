From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: [RESEND PATCH 4/6] staging: fsl-dpaa2/ethsw: Add maintainer for Ethernet Switch driver
Date: Tue, 19 Sep 2017 15:45:56 +0300
Message-ID: <1505825158-8192-5-git-send-email-razvan.stefanescu@nxp.com>
References: <1505825158-8192-1-git-send-email-razvan.stefanescu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devel@driverdev.osuosl.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <agraf@suse.de>, <arnd@arndb.de>,
        <alexandru.marginean@nxp.com>, <bogdan.purcareata@nxp.com>,
        <ruxandra.radulescu@nxp.com>, <laurentiu.tudor@nxp.com>,
        <stuyoder@gmail.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505825158-8192-1-git-send-email-razvan.stefanescu@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Razvan Stefanescu <razvan.stefanescu@nxp.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2281af4..cfd4f74 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4297,6 +4297,12 @@ L:	linux-kernel@vger.kernel.org
 S:	Maintained
 F:	drivers/staging/fsl-dpaa2/ethernet
 
+DPAA2 ETHERNET SWITCH DRIVER
+M:	Razvan Stefanescu <razvan.stefanescu@nxp.com>
+L:	linux-kernel@vger.kernel.org
+S:	Maintained
+F:	drivers/staging/fsl-dpaa2/ethsw
+
 DPT_I2O SCSI RAID DRIVER
 M:	Adaptec OEM Raid Solutions <aacraid@adaptec.com>
 L:	linux-scsi@vger.kernel.org
-- 
1.9.1
