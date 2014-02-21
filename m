From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 7/7] Update MAINTAINERS for qlcnic driver
Date: Fri, 21 Feb 2014 13:20:16 -0500
Message-ID: <1393006816-20294-8-git-send-email-shahed.shaikh@qlogic.com>
References: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:61851 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755781AbaBUSzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 13:55:53 -0500
In-Reply-To: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Keep myself as only maintainer for qlcnic driver and update
group email alias to Dept-HSGLinuxNICDev@qlogic.com

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 MAINTAINERS | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index db8bb0d..c970557 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7037,13 +7037,8 @@ F:	Documentation/networking/LICENSE.qla3xxx
 F:	drivers/net/ethernet/qlogic/qla3xxx.*
 
 QLOGIC QLCNIC (1/10)Gb ETHERNET DRIVER
-M:	Himanshu Madhani <himanshu.madhani@qlogic.com>
-M:	Rajesh Borundia <rajesh.borundia@qlogic.com>
 M:	Shahed Shaikh <shahed.shaikh@qlogic.com>
-M:	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
-M:	Sony Chacko <sony.chacko@qlogic.com>
-M:	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
-M:	linux-driver@qlogic.com
+M:	Dept-HSGLinuxNICDev@qlogic.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/qlogic/qlcnic/
-- 
1.8.1.4
