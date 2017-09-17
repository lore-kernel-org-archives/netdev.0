From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 6/7] net: korina: update authors
Date: Sun, 17 Sep 2017 20:25:11 +0300
Message-ID: <20170917172511.32586-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:38657 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdIQRZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:25:13 -0400
Received: by mail-lf0-f68.google.com with SMTP id m199so3438694lfe.5
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:25:12 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id t63sm1421597lje.81.2017.09.17.10.25.10
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:25:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index c26f0d84ba6b..d58aa4bfcb58 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -4,6 +4,7 @@
  *  Copyright 2004 IDT Inc. (rischelp@idt.com)
  *  Copyright 2006 Felix Fietkau <nbd@openwrt.org>
  *  Copyright 2008 Florian Fainelli <florian@openwrt.org>
+ *  Copyright 2017 Roman Yeryomin <roman@advem.lv>
  *
  *  This program is free software; you can redistribute  it and/or modify it
  *  under  the terms of  the GNU General  Public License as published by the
@@ -1150,5 +1151,6 @@ module_platform_driver(korina_driver);
 MODULE_AUTHOR("Philip Rischel <rischelp@idt.com>");
 MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
 MODULE_AUTHOR("Florian Fainelli <florian@openwrt.org>");
+MODULE_AUTHOR("Roman Yeryomin <roman@advem.lv>");
 MODULE_DESCRIPTION("IDT RC32434 (Korina) Ethernet driver");
 MODULE_LICENSE("GPL");
-- 
2.11.0
