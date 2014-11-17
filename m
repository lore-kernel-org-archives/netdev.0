From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 0/8] net: fec: assorted cleanup patches
Date: Mon, 17 Nov 2014 10:51:16 +0100
Message-ID: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <fugang.duan@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53277 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbaKQJvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 04:51:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a followup to:
<1415350967-2238-1-git-send-email-LW@KARO-electronics.de>
[PATCHv4 1/1] net: fec: fix regression on i.MX28 introduced by rx_copybreak support
to apply the cleanup patches that were originally sent along with the
bugfix patch.
