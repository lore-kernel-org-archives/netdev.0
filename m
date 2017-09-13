From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] MAINTAINERS: review Renesas DT bindings as well
Date: Wed, 13 Sep 2017 22:28:53 +0300
Message-ID: <20170913192913.138491844@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:44989 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751885AbdIMT3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 15:29:18 -0400
Received: by mail-lf0-f45.google.com with SMTP id l196so3210384lfl.1
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 12:29:17 -0700 (PDT)
Content-Disposition: inline; filename=MAINTAINERS-review-Renesas-DT-bindings-as-well.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding myself  as a reviewer for  the Renesas  Ethernet drivers
I somehow forgot about the bindings -- I want to review them as well.

Fixes: 8e6569af3a1b ("MAINTAINERS: add myself as Renesas Ethernet drivers reviewer")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

 MAINTAINERS |    2 ++
 1 file changed, 2 insertions(+)

Index: net/MAINTAINERS
===================================================================
--- net.orig/MAINTAINERS
+++ net/MAINTAINERS
@@ -11379,6 +11379,8 @@ RENESAS ETHERNET DRIVERS
 R:	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
 L:	netdev@vger.kernel.org
 L:	linux-renesas-soc@vger.kernel.org
+F:	Documentation/devicetree/bindings/net/renesas,*.txt
+F:	Documentation/devicetree/bindings/net/sh_eth.txt
 F:	drivers/net/ethernet/renesas/
 F:	include/linux/sh_eth.h
 
