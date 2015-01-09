From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH] MAINTAINERS: add me as ibmveth maintainer
Date: Fri,  9 Jan 2015 14:29:40 -0600
Message-ID: <1420835380-2824-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Santiago Leon <santi_leon@yahoo.com>,
	Brian King <brking@linux.vnet.ibm.com>,
	Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:48380 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223AbbAIU3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 15:29:51 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Fri, 9 Jan 2015 15:29:50 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 53CD538C8052
	for <netdev@vger.kernel.org>; Fri,  9 Jan 2015 15:29:44 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t09KThgO28770342
	for <netdev@vger.kernel.org>; Fri, 9 Jan 2015 20:29:43 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t09KTggO031692
	for <netdev@vger.kernel.org>; Fri, 9 Jan 2015 15:29:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding myself as the ibmveth maintainer and replacing
Santiago Leon.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Cc: Santiago Leon <santi_leon@yahoo.com>
Cc: Brian King <brking@linux.vnet.ibm.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ddb9ac8..5cb9f6f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4748,7 +4748,7 @@ S:	Supported
 F:	drivers/scsi/ipr.*
 
 IBM Power Virtual Ethernet Device Driver
-M:	Santiago Leon <santil@linux.vnet.ibm.com>
+M:	Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/ibm/ibmveth.*
-- 
1.9.3
