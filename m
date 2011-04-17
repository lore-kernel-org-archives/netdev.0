From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: add Realtek as maintainer.
Date: Sun, 17 Apr 2011 16:15:12 +0200
Message-ID: <20110417141512.GA18236@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60282 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab1DQOXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 10:23:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per Hayes's request.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 MAINTAINERS |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ec36003..1e2724e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -151,6 +151,7 @@ S:	Maintained
 F:	drivers/net/hamradio/6pack.c
 
 8169 10/100/1000 GIGABIT ETHERNET DRIVER
+M:	Realtek linux nic maintainers <nic_swsd@realtek.com>
 M:	Francois Romieu <romieu@fr.zoreil.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-- 
1.7.4.2

