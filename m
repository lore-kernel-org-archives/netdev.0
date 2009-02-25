From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 24/26] RDS: Add MAINTAINERS entry
Date: Tue, 24 Feb 2009 17:30:41 -0800
Message-ID: <1235525443-9007-25-git-send-email-andy.grover@oracle.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:59739 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922AbZBYBbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:31:42 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 MAINTAINERS |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 59fd2d1..fd68b34 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3639,6 +3639,12 @@ M:	florian.fainelli@telecomint.eu
 L:	netdev@vger.kernel.org
 S:	Maintained
 
+RDS - RELIABLE DATAGRAM SOCKETS
+P:	Andy Grover
+M:	andy.grover@oracle.com
+L:	rds-devel@oss.oracle.com
+S:	Supported
+
 READ-COPY UPDATE (RCU)
 P:	Dipankar Sarma
 M:	dipankar@in.ibm.com
-- 
1.5.6.3

