From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/3] MAINTAINERS: update S390 NETWORK DRIVERS maintainer
Date: Fri, 27 Feb 2015 12:52:34 +0100
Message-ID: <1425037954-50840-4-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1425037954-50840-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:55587 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbbB0Lx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 06:53:27 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 27 Feb 2015 11:53:26 -0000
In-Reply-To: <1425037954-50840-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

remove Frank Blaschka as S390 NETWORK DRIVERS maintainer

Acked-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0597c5b..274a005 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8328,7 +8328,6 @@ F:	block/partitions/ibm.c
 
 S390 NETWORK DRIVERS
 M:	Ursula Braun <ursula.braun@de.ibm.com>
-M:	Frank Blaschka <blaschka@linux.vnet.ibm.com>
 M:	linux390@de.ibm.com
 L:	linux-s390@vger.kernel.org
 W:	http://www.ibm.com/developerworks/linux/linux390/
-- 
2.1.4
