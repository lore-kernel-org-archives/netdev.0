From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 6/6] cnic: Update version to 2.1.3.
Date: Thu, 24 Jun 2010 17:58:42 -0700
Message-ID: <1277427522-17306-6-git-send-email-mchan@broadcom.com>
References: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
 <1277427522-17306-2-git-send-email-mchan@broadcom.com>
 <1277427522-17306-3-git-send-email-mchan@broadcom.com>
 <1277427522-17306-4-git-send-email-mchan@broadcom.com>
 <1277427522-17306-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3196 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027Ab0FYA4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 20:56:19 -0400
In-Reply-To: <1277427522-17306-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/cnic_if.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 0c55177..344c842 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.1.2"
-#define CNIC_MODULE_RELDATE	"May 26, 2010"
+#define CNIC_MODULE_VERSION	"2.1.3"
+#define CNIC_MODULE_RELDATE	"June 24, 2010"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT


