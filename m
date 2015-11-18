From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net ipv4: use preferred log methods
Date: Wed, 18 Nov 2015 13:38:18 -0500 (EST)
Message-ID: <20151118.133818.2151892837079203258.davem@davemloft.net>
References: <1443625231-1871-1-git-send-email-bst@pengutronix.de>
	<1447411234-2067-1-git-send-email-bst@pengutronix.de>
	<1447411234-2067-2-git-send-email-bst@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, trivial@kernel.org,
	kernel@pengutronix.de
To: bst@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbbKRSiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 13:38:22 -0500
In-Reply-To: <1447411234-2067-2-git-send-email-bst@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bastian Stender <bst@pengutronix.de>
Date: Fri, 13 Nov 2015 11:40:34 +0100

> Replace printk calls with preferred unconditional log method calls to keep
> kernel messages clean.
> 
> Added newline to "too small MTU" message.
> 
> Signed-off-by: Bastian Stender <bst@pengutronix.de>

Applied to net-next, thanks.
