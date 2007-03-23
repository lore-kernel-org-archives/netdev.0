From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 5/5 2.6.21-rc4] l2tp: add pppol2tp maintainer
Date: Fri, 23 Mar 2007 23:07:27 GMT
Message-ID: <200703232307.l2NN7Rn4010821@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33025 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992617AbXCWXIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:08:11 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HUsrY-00055b-St
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 18:08:01 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l2NN7S96010843
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 23:07:28 GMT
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l2NN7Rn4010821
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 23:07:27 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPPOL2TP]: Update maintainers file for PPP over L2TP.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21-rc4/MAINTAINERS
===================================================================
--- linux-2.6.21-rc4.orig/MAINTAINERS
+++ linux-2.6.21-rc4/MAINTAINERS
@@ -2700,6 +2700,11 @@ P:	Michal Ostrowski
 M:	mostrows@speakeasy.net
 S:	Maintained
 
+PPP OVER L2TP
+P:	James Chapman
+M:	jchapman@katalix.com
+S:	Maintained
+
 PREEMPTIBLE KERNEL
 P:	Robert Love
 M:	rml@tech9.net
