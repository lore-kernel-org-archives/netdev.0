From: akpm@linux-foundation.org
Subject: [patch 18/18] 3c59x maintainer
Date: Fri, 10 Aug 2007 14:05:27 -0700
Message-ID: <200708102105.l7AL5RYL008998@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	klassert@mathematik.tu-chemnitz.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44165 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751266AbXHJVQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

Add 3c59x maintainer.

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 MAINTAINERS |    6 ++++++
 1 files changed, 6 insertions(+)

diff -puN MAINTAINERS~add-3c59x-maintainer MAINTAINERS
--- a/MAINTAINERS~add-3c59x-maintainer
+++ a/MAINTAINERS
@@ -97,6 +97,12 @@ M:	philb@gnu.org
 L:	netdev@vger.kernel.org
 S:	Maintained
 
+3C59X NETWORK DRIVER
+P:	Steffen Klassert
+M:	klassert@mathematik.tu-chemnitz.de
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 3CR990 NETWORK DRIVER
 P:	David Dillow
 M:	dave@thedillows.org
_
