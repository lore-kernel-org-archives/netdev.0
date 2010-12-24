From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 10/10] bna: Update the driver version to 2.3.2.3
Date: Thu, 23 Dec 2010 23:45:10 -0800
Message-ID: <1293176710-21335-11-git-send-email-rmody@brocade.com>
References: <1293176710-21335-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangj@brocade.com>, Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54216 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750784Ab0LXHqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Dec 2010 02:46:31 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBO7kVYT012868
	for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 23:46:31 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0b-000f0801.pphosted.com with ESMTP id tck2q82py-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 23:46:30 -0800
In-Reply-To: <1293176710-21335-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 1954dea..8b1d515 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -65,7 +65,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"2.3.2.0"
+#define BNAD_VERSION			"2.3.2.3"
 
 #define BNAD_MAILBOX_MSIX_VECTORS	1
 
-- 
1.7.1

