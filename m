From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 4/5 2.6.21] L2TP: Add PPPoL2TP maintainer
Date: Mon, 30 Apr 2007 10:52:01 +0100
Message-ID: <200704300952.l3U9q1dj031853@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:42314 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031521AbXD3Jwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 05:52:43 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HiSYj-0006EZ-NG
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 04:52:42 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3U9q1VC031862
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 10:52:01 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3U9q1dj031853
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 10:52:01 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21/MAINTAINERS
===================================================================
--- linux-2.6.21.orig/MAINTAINERS
+++ linux-2.6.21/MAINTAINERS
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
