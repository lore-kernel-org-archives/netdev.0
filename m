From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] MAINAINTERS: Add Doug as GENET maintainer
Date: Thu, 26 Oct 2017 09:11:48 -0700
Message-ID: <20171026161148.27947-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:57179 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932309AbdJZQL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 12:11:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id r79so3676976wrb.13
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 09:11:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e3a7ca9d2783..02c965516671 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2897,6 +2897,7 @@ F:	drivers/gpio/gpio-brcmstb.c
 F:	Documentation/devicetree/bindings/gpio/brcm,brcmstb-gpio.txt
 
 BROADCOM GENET ETHERNET DRIVER
+M:	Doug Berger <opendmb@gmail.com>
 M:	Florian Fainelli <f.fainelli@gmail.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-- 
2.9.3
