From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 4/5 2.6.22-rc6] L2TP: Add PPPoL2TP maintainer
Date: Wed, 27 Jun 2007 23:20:38 +0100
Message-ID: <200706272220.l5RMKcNR004951@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60939 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759681AbXF0WVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 18:21:20 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1I3fk3-00050Q-Au
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 17:12:03 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l5RMKclx004961
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 23:20:38 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l5RMKcNR004951
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 23:20:38 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.22-rc6/MAINTAINERS
===================================================================
--- linux-2.6.22-rc6.orig/MAINTAINERS
+++ linux-2.6.22-rc6/MAINTAINERS
@@ -2903,6 +2903,11 @@ P:	Michal Ostrowski
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
