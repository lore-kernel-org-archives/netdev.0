From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 5/5 2.6.21-rc7] l2tp: add pppol2tp maintainer
Date: Mon, 23 Apr 2007 13:56:40 +0100
Message-ID: <200704231256.l3NCuejH028390@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37868 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161535AbXDWM5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 08:57:23 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1Hfy6Z-00077g-78
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 07:57:19 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3NCuf1A028399
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 13:56:41 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3NCuejH028390
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 13:56:40 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[L2TP]: Update maintainers file for PPP over L2TP.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21-rc7/MAINTAINERS
===================================================================
--- linux-2.6.21-rc7.orig/MAINTAINERS
+++ linux-2.6.21-rc7/MAINTAINERS
@@ -2709,6 +2709,11 @@ P:	Michal Ostrowski
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
