From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: don't accept multicast traffic with scop 0
Date: Mon, 11 Feb 2013 14:01:44 -0500 (EST)
Message-ID: <20130211.140144.1091885235469101624.davem@davemloft.net>
References: <20130210153522.GA20897@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758123Ab3BKTBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:01:47 -0500
In-Reply-To: <20130210153522.GA20897@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 10 Feb 2013 16:35:22 +0100

> v2:
> a) moved before multicast source address check
> b) changed comment to netdev style
> 
> Cc: Erik Hugne <erik.hugne@ericsson.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
