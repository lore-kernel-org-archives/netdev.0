From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 3/3] MAINTAINERS: add Julian Wiedmann
Date: Thu, 23 Mar 2017 14:55:10 +0100
Message-ID: <20170323135510.98972-4-ubraun@linux.vnet.ibm.com>
References: <20170323135510.98972-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49588 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755615AbdCWNzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:55:23 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2NDrq6u145085
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:22 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29bxj17rxv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:21 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 23 Mar 2017 13:55:20 -0000
In-Reply-To: <20170323135510.98972-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Julian Wiedmann as additional maintainer for drivers/s390/net
and net/iucv.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 MAINTAINERS | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index c45c02b..e48678d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10808,6 +10808,7 @@ F:	drivers/s390/block/dasd*
 F:	block/partitions/ibm.c
 
 S390 NETWORK DRIVERS
+M:	Julian Wiedmann <jwi@linux.vnet.ibm.com>
 M:	Ursula Braun <ubraun@linux.vnet.ibm.com>
 L:	linux-s390@vger.kernel.org
 W:	http://www.ibm.com/developerworks/linux/linux390/
@@ -10838,6 +10839,7 @@ S:	Supported
 F:	drivers/s390/scsi/zfcp_*
 
 S390 IUCV NETWORK LAYER
+M:	Julian Wiedmann <jwi@linux.vnet.ibm.com>
 M:	Ursula Braun <ubraun@linux.vnet.ibm.com>
 L:	linux-s390@vger.kernel.org
 W:	http://www.ibm.com/developerworks/linux/linux390/
-- 
2.8.4
