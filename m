From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCHv3 net-next-2.6 3/3] qlcnic: Bumped up version number to 5.0.18
Date: Thu, 12 May 2011 15:48:35 -0700
Message-ID: <1305240515-29237-5-git-send-email-anirban.chakraborty@qlogic.com>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:58542 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754103Ab1ELWzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 18:55:00 -0400
In-Reply-To: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update driver version number

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 689adea..480ef5c 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 17
-#define QLCNIC_LINUX_VERSIONID  "5.0.17"
+#define _QLCNIC_LINUX_SUBVERSION 18
+#define QLCNIC_LINUX_VERSIONID  "5.0.18"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.7.4.1

