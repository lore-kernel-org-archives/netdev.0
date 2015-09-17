From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] MAINTAINERS: remove bouncing email address for qlcnic
Date: Thu, 17 Sep 2015 16:28:31 +0200
Message-ID: <69f160ea1688957f19ec468697fbe719ac0668eb.1442500106.git.jbenc@redhat.com>
Cc: Dept-GELinuxNICDev@qlogic.com, Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175AbbIQO2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:28:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got this automated message from <shahed.shaikh@qlogic.com> when submitting
a qlcnic patch:

> Shahed Shaikh is no longer with QLogic. If you require assistance please
> contact Ariel Elior Ariel.Elior@qlogic.com

There's no point in having a bouncing address in MAINTAINERS.

CC: Dept-GELinuxNICDev@qlogic.com
CC: Ariel Elior <Ariel.Elior@qlogic.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 310da4295c70..0f0dcfd2d68d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8490,7 +8490,6 @@ F:	Documentation/networking/LICENSE.qla3xxx
 F:	drivers/net/ethernet/qlogic/qla3xxx.*
 
 QLOGIC QLCNIC (1/10)Gb ETHERNET DRIVER
-M:	Shahed Shaikh <shahed.shaikh@qlogic.com>
 M:	Dept-GELinuxNICDev@qlogic.com
 L:	netdev@vger.kernel.org
 S:	Supported
-- 
1.8.3.1
