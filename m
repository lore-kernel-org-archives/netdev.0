From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Update module author
Date: Wed, 31 May 2017 15:35:31 -0500
Message-ID: <1496262931-15978-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34084 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751034AbdEaUfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 16:35:45 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4VKYbeI106548
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 16:35:44 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2at3r03dau-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 16:35:44 -0400
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 31 May 2017 14:35:43 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the module author to be one of the original co-maintainers
of the driver. The original author left the project long ago and
so far has not responded to emails sent to the listed address.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4f2d329..3e4a858 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -81,7 +81,7 @@
 static const char ibmvnic_driver_name[] = "ibmvnic";
 static const char ibmvnic_driver_string[] = "IBM System i/p Virtual NIC Driver";
 
-MODULE_AUTHOR("Santiago Leon <santi_leon@yahoo.com>");
+MODULE_AUTHOR("Thomas Falcon <tlfalcon@linux.vnet.ibm.com>");
 MODULE_DESCRIPTION("IBM System i/p Virtual NIC Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(IBMVNIC_DRIVER_VERSION);
-- 
2.7.4
