From: Jon Mason <jdmason@us.ibm.com>
Subject: No Maintainer entry for dl2k driver
Date: Fri, 17 Dec 2004 16:13:43 -0600
Message-ID: <200412171613.43330.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It has come to my attention that there is no entry in the kernel MAINTAINERS 
file for the D-Link Gigabit Ethernet Driver (and possibly no maintainer).  
So, I have created a patch for that file with an entry for the driver status 
as Orphaned.

--- MAINTAINERS.orig    2004-12-17 16:01:37.955336376 -0600
+++ MAINTAINERS 2004-12-17 16:07:21.027181528 -0600
@@ -704,6 +704,10 @@ M: mvw@planets.elm.net
 L:     linux-kernel@vger.kernel.org
 S:     Maintained

+DL2K NETWORK DRIVER
+L:     linux-net@vger.kernel.org
+S:     Orphan
+
 DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
 P:     Tobias Ringstrom
 M:     tori@unhappy.mine.nu

-- 
Jon Mason
jdmason@us.ibm.com
