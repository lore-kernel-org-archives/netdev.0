From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] gtp: add MAINTAINERS
Date: Fri, 10 Feb 2017 12:29:05 +0100
Message-ID: <1486726145-31755-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org, laforge@gnumonks.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54776 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753145AbdBJL3a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 06:29:30 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 8DC6C1C4390
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 12:29:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7C846BAC2C
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 12:29:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 10486BAC50
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 12:29:18 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add maintainers for this tunnel driver. Include main osmocom.org mailist
list too.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5864bbd99f8f..ce5dde23bd00 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5638,6 +5638,14 @@ T:	git git://linuxtv.org/media_tree.git
 S:	Odd Fixes
 F:	drivers/media/usb/gspca/
 
+GTP (GPRS Tunneling Protocol)
+M:	Pablo Neira Ayuso <pablo@netfilter.org>
+M:	Harald Welte <laforge@gnumonks.org>
+L:	openbsc@lists.osmocom.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pablo/gtp.git
+S:	Maintained
+F:	drivers/net/gtp.c
+
 GUID PARTITION TABLE (GPT)
 M:	Davidlohr Bueso <dave@stgolabs.net>
 L:	linux-efi@vger.kernel.org
-- 
2.1.4
