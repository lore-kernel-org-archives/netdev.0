From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 1/1] add b44 to maintainers
Date: Thu, 22 Jun 2006 17:26:20 -0700
Message-ID: <1151022380.20563.14.camel@dhcp-10-7-81-7.broadcom.com>
References: <1151021430.20563.10.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:46853 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1161459AbWFWA07
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 20:26:59 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <1151021430.20563.10.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add b44 to the MAINTAINERS file.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 1421f74..a52e9c0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -568,6 +568,12 @@ L:	linuxppc-dev@ozlabs.org
 W:	http://www.penguinppc.org/ppc64/
 S:	Supported
 
+BROADCOM B44 10/100 ETHERNET DRIVER
+P:	Gary Zambrano
+M:	zambrano@broadcom.com
+L:	netdev@vger.kernel.org
+S:	Supported
+
 BROADCOM BNX2 GIGABIT ETHERNET DRIVER
 P:	Michael Chan
 M:	mchan@broadcom.com


