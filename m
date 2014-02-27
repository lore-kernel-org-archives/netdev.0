From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 1/2] gitignore: ignore test-driver
Date: Wed, 26 Feb 2014 17:35:10 -0800
Message-ID: <1393464911-21593-2-git-send-email-f.fainelli@gmail.com>
References: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:22902 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbaB0BfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 20:35:19 -0500
In-Reply-To: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .gitignore | 1 +
 1 file changed, 1 insertion(+)

diff --git a/.gitignore b/.gitignore
index 45c95015df1b..b03b56f88132 100644
--- a/.gitignore
+++ b/.gitignore
@@ -13,6 +13,7 @@ ethtool.spec
 ethtool.8
 ethtool
 test-cmdline
+test-driver
 test-features
 stamp-h1
 config.*
-- 
1.8.3.2
