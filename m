From: paul.moore@hp.com
Subject: [PATCH] Netlink: add a pointer to the Generic Netlink wiki page
Date: Tue, 05 Dec 2006 12:26:10 -0500
Message-ID: <20061205172625.536651000@hp.com>
References: <20061205172609.850935000@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:52373 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968494AbWLER2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 12:28:45 -0500
Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel9.hp.com (Postfix) with ESMTP id F0F7338E04
	for <netdev@vger.kernel.org>; Tue,  5 Dec 2006 12:27:59 -0500 (EST)
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=netlink-genl_wiki_pointer
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Add a pointer to the OSDL wiki page on Generic Netlink.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 Documentation/networking/00-INDEX            |    2 ++
 Documentation/networking/generic_netlink.txt |    3 +++
 2 files changed, 5 insertions(+)

Index: net-2.6.20_netlink-doc/Documentation/networking/00-INDEX
===================================================================
--- net-2.6.20_netlink-doc.orig/Documentation/networking/00-INDEX
+++ net-2.6.20_netlink-doc/Documentation/networking/00-INDEX
@@ -58,6 +58,8 @@ fore200e.txt
 	- FORE Systems PCA-200E/SBA-200E ATM NIC driver info.
 framerelay.txt
 	- info on using Frame Relay/Data Link Connection Identifier (DLCI).
+generic_netlink.txt
+	- info on Generic Netlink
 ip-sysctl.txt
 	- /proc/sys/net/ipv4/* variables
 ip_dynaddr.txt
Index: net-2.6.20_netlink-doc/Documentation/networking/generic_netlink.txt
===================================================================
--- /dev/null
+++ net-2.6.20_netlink-doc/Documentation/networking/generic_netlink.txt
@@ -0,0 +1,3 @@
+A wiki document on how to use Generic Netlink can be found here:
+
+ * http://linux-net.osdl.org/index.php/Generic_Netlink_HOWTO

--
paul moore
linux security @ hp

