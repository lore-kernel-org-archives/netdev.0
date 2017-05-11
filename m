From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net 2/2] qlcnic: Update version to 5.3.66
Date: Thu, 11 May 2017 07:12:48 -0700
Message-ID: <20170511141248.996-3-manish.chopra@cavium.com>
References: <20170511141248.996-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0084.outbound.protection.outlook.com ([104.47.40.84]:18689
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932245AbdEKONK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 11 May 2017 10:13:10 -0400
In-Reply-To: <20170511141248.996-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bumping up the version as couple of fixes added after 5.3.65

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 49bad00..7245b10 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -37,8 +37,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 3
-#define _QLCNIC_LINUX_SUBVERSION 65
-#define QLCNIC_LINUX_VERSIONID  "5.3.65"
+#define _QLCNIC_LINUX_SUBVERSION 66
+#define QLCNIC_LINUX_VERSIONID  "5.3.66"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
2.7.2
