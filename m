From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH] ping doc: Fix typo.
Date: Fri, 18 Jan 2013 12:21:36 +0100
Message-ID: <1358508096-19915-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab3ARLVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 06:21:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 doc/ping.sgml | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/doc/ping.sgml b/doc/ping.sgml
index 4e0e65f..eec92a2 100644
--- a/doc/ping.sgml
+++ b/doc/ping.sgml
@@ -600,7 +600,7 @@ Many Hosts and Gateways ignore the RECORD_ROUTE option.
  <listitem><para>
 The maximum IP header length is too small for options like
 RECORD_ROUTE to be completely useful.
-There's not much that that can be done about this, however.
+There's not much that can be done about this, however.
  </para></listitem>
  <listitem><para>
 Flood pinging is not recommended in general, and flood pinging the
-- 
1.8.0.2
