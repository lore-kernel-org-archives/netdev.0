From: Jim Lewis <jklewis@us.ibm.com>
Subject: [PATCH]: Add to MAINTAINERS file
Date: Mon, 28 Aug 2006 13:18:35 -0500
Message-ID: <1156789115.25559.15.camel@lewis1.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:57509 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751251AbWH1SSi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 14:18:38 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SIIcaM022804
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 14:18:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SIIbfX222412
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 12:18:37 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SIIaJm011926
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 12:18:37 -0600
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds Jim Lewis to the MAINTAINERS file for the Spidernet
network driver.

Signed-off-by: James K Lewis <jklewis@us.ibm.com>


---
 MAINTAINERS |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6.18-rc2/MAINTAINERS
===================================================================
--- linux-2.6.18-rc2.orig/MAINTAINERS	2006-08-21 16:59:25.000000000
-0500
+++ linux-2.6.18-rc2/MAINTAINERS	2006-08-21 17:19:14.000000000 -0500
@@ -2702,6 +2702,12 @@ M:	R.E.Wolff@BitWizard.nl
 L:	linux-kernel@vger.kernel.org ?
 S:	Supported
 
+SPIDERNET NETWORK DRIVER for CELL
+P:	Jim Lewis
+M:	jim@jklewis.com
+L:	netdev@vger.kernel.org
+S:	Supported
+
 SRM (Alpha) environment access
 P:	Jan-Benedict Glaw
 M:	jbglaw@lug-owl.de


