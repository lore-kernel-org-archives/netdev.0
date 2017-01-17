From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [net, 5/6] net: korina: update authors
Date: Tue, 17 Jan 2017 19:33:03 +0200
Message-ID: <1484674383-22465-1-git-send-email-roman@advem.lv>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33721 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751447AbdAQRkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:40:04 -0500
Received: by mail-lf0-f65.google.com with SMTP id x1so11921078lff.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 09:40:03 -0800 (PST)
Received: from ubrain.lan ([213.175.92.61])
        by smtp.googlemail.com with ESMTPSA id v18sm4359434lja.31.2017.01.17.09.33.06
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 09:33:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index afa440c..83c994f 100644
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
2.7.4
