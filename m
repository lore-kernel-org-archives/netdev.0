From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] MAINTAINERS: Add VRF entry
Date: Tue, 25 Aug 2015 10:26:22 -0700
Message-ID: <1440523582-19946-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33649 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbbHYR03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 13:26:29 -0400
Received: by pacti10 with SMTP id ti10so57312879pac.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 10:26:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add entry for new VRF device driver.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7b528b8c73f8..65d3b389c5c0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11063,6 +11063,14 @@ S:	Supported
 F:	drivers/regulator/
 F:	include/linux/regulator/
 
+VRF
+M:	David Ahern <dsa@cumulusnetworks.com>
+M:	Shrijeet Mukherjee <shm@cumulusnetworks.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/vrf.c
+F:	include/net/vrf.h
+
 VT1211 HARDWARE MONITOR DRIVER
 M:	Juerg Haefliger <juergh@gmail.com>
 L:	lm-sensors@lm-sensors.org
-- 
2.3.2 (Apple Git-55)
