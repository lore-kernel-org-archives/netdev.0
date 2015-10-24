From: David Miller <davem@davemloft.net>
Subject: Re: net: fec: stable queue request
Date: Sat, 24 Oct 2015 04:56:24 -0700 (PDT)
Message-ID: <20151024.045624.1494885395351787548.davem@davemloft.net>
References: <1445433600.3196.9.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbbJXLjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 07:39:51 -0400
In-Reply-To: <1445433600.3196.9.camel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Wed, 21 Oct 2015 15:20:00 +0200

> can you please add
> 
> b0c6ce24911fcb64715de9569f0f7b4f54d1d045
> net: fec: Remove unneeded use of IS_ERR_VALUE() macro
> 
> 42ea4457aea7aaeddf0c0b06724f297608f5e9d2
> net: fec: normalize return value of pm_runtime_get_sync() in MDIO write
> 
> to your stable 4.2+ queue?

Done.
