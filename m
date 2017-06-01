From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v2] ibmvnic: Remove module author mailing address
Date: Thu,  1 Jun 2017 15:32:34 -0500
Message-ID: <1496349154-26479-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: davem@davemloft.net, nfont@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60834 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751122AbdFAUcw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 16:32:52 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v51KSY3p060426
        for <netdev@vger.kernel.org>; Thu, 1 Jun 2017 16:32:41 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2atmfayyp3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 16:32:41 -0400
Received: from localhost
        by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 1 Jun 2017 14:32:40 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original author left the project and so far has not
responded to emails sent to the listed address.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v2: only remove invalid email address
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4f2d329..a93757c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -81,7 +81,7 @@
 static const char ibmvnic_driver_name[] = "ibmvnic";
 static const char ibmvnic_driver_string[] = "IBM System i/p Virtual NIC Driver";
 
-MODULE_AUTHOR("Santiago Leon <santi_leon@yahoo.com>");
+MODULE_AUTHOR("Santiago Leon");
 MODULE_DESCRIPTION("IBM System i/p Virtual NIC Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(IBMVNIC_DRIVER_VERSION);
-- 
2.7.4
