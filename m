From: "cwm97m" <cwm97m@cse.nsysu.edu.tw>
Subject: [Patch linux-2.6.28-rc7 1/1] jme: Fixed a typo
Date: Wed, 17 Dec 2008 14:28:44 +0800
Message-ID: <20081217062724.M28688@cse.nsysu.edu.tw>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cse.nsysu.edu.tw ([140.117.11.85]:51734 "EHLO
	mail.cse.nsysu.edu.tw" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751173AbYLQGux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 01:50:53 -0500
Received: from cse.nsysu.edu.tw (localhost.cse.nsysu.edu.tw [127.0.0.1])
	by mail.cse.nsysu.edu.tw (Postfix) with ESMTP id 23A27660816C
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 14:28:44 +0800 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Found a typo.

Signed-off-by: Wei-Min Chen <cwm97m@cse.nsysu.edu.tw>

--- linux-2.6.28-rc7/drivers/net/jme.h.orig	2008-12-17 14:14:56.000000000 +0800
+++ linux-2.6.28-rc7/drivers/net/jme.h	2008-12-17 14:15:30.000000000 +0800
@@ -22,7 +22,7 @@
  */
 
 #ifndef __JME_H_INCLUDED__
-#define __JME_H_INCLUDEE__
+#define __JME_H_INCLUDED__
 
 #define DRV_NAME	"jme"
 #define DRV_VERSION	"1.0.3"

