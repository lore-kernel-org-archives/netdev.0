From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: cpsw: Search childs for slave nodes
Date: Mon, 07 Oct 2013 15:19:50 -0400 (EDT)
Message-ID: <20131007.151950.425314304695719989.davem@davemloft.net>
References: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, mugunthanvnm@ti.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: mpa@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab3JGTTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:19:53 -0400
In-Reply-To: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>
Date: Fri,  4 Oct 2013 14:44:39 +0200

> The current implementation searches the whole DT for nodes named
> "slave".
> 
> This patch changes it to search only child nodes for slaves.
> 
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>

Applied.
