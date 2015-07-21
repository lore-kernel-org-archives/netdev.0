From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix runtime PM when probing MII bus
Date: Mon, 20 Jul 2015 17:14:56 -0700 (PDT)
Message-ID: <20150720.171456.561473422997220138.davem@davemloft.net>
References: <1437400094-11453-1-git-send-email-l.stach@pengutronix.de>
	<20150720235224.GA22909@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: l.stach@pengutronix.de, fugang.duan@freescale.com,
	Frank.Li@freescale.com, netdev@vger.kernel.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbGUAO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 20:14:58 -0400
In-Reply-To: <20150720235224.GA22909@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 21 Jul 2015 01:52:24 +0200

> You emailed saying you had reverted 6c3e921b18ed, but it is still in
> net-next/master.

It's reverted in the 'net' tree, and that's where bug fixes go.

'net' is periodically merged into 'net-next' so even if the revert
isn't there now, it should show up there eventually.
