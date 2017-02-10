From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next,v2] gtp: add MAINTAINERS
Date: Fri, 10 Feb 2017 13:26:27 +0100
Message-ID: <1486729587-501-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, laforge@gnumonks.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38246 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751674AbdBJM2E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 07:28:04 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5E5B91C4390
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 13:26:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4F10DDA81A
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 13:26:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BE935DA856
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 13:26:32 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira <pablo@netfilter.org>

Add maintainers for this tunnel driver. Include main osmocom.org mailist
list too.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
v2: Harald suggests osmocom-net-gprs@lists.osmocom.org is better ML for this.

 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5864bbd99f8f..e2dfc4377f4b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5638,6 +5638,14 @@ T:	git git://linuxtv.org/media_tree.git
 S:	Odd Fixes
 F:	drivers/media/usb/gspca/
 
+GTP (GPRS Tunneling Protocol)
+M:	Pablo Neira Ayuso <pablo@netfilter.org>
+M:	Harald Welte <laforge@gnumonks.org>
+L:	osmocom-net-gprs@lists.osmocom.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pablo/gtp.git
+S:	Maintained
+F:	drivers/net/gtp.c
+
 GUID PARTITION TABLE (GPT)
 M:	Davidlohr Bueso <dave@stgolabs.net>
 L:	linux-efi@vger.kernel.org
-- 
2.1.4
