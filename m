From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: [PATCH 1/1] Update maintainer for EHEA driver.
Date: Mon, 18 Jul 2016 12:28:45 -0500
Message-ID: <1468862925-21730-1-git-send-email-dougmill@linux.vnet.ibm.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@cascardo.eti.br>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:4738 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750965AbcGRR3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 13:29:08 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6IHNnVA027939
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 13:29:02 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 248nbjbn8m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 13:29:02 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Mon, 18 Jul 2016 11:29:01 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since Thadeu left IBM, EHEA has gone mostly unmaintained, since his email
address doesn't work anymore.  I'm stepping up to help maintain this
driver upstream.

I'm adding Thadeu's personal e-mail address in Cc, hoping that we can
get his ack.

CC: Thadeu Lima de Souza Cascardo <cascardo@cascardo.eti.br>
Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
---
 MAINTAINERS |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1d74837..e9cefe2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4477,7 +4477,7 @@ S:	Orphan
 F:	fs/efs/
 
 EHEA (IBM pSeries eHEA 10Gb ethernet adapter) DRIVER
-M:	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
+M:	Douglas Miller <dougmill@linux.vnet.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ethernet/ibm/ehea/
-- 
1.7.1
