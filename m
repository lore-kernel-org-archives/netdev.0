From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference in veth_stats_one
Date: Mon, 07 Jan 2013 19:43:16 -0800 (PST)
Message-ID: <20130107.194316.1611337776405613841.davem@davemloft.net>
References: <1357327406.1678.2139.camel@edumazet-glaptop>
	<1357331112.2693.33.camel@bwh-desktop.uk.solarflarecom.com>
	<1357350160.1678.3303.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, tparkin@katalix.com,
	netdev@vger.kernel.org
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338Ab3AHDnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:43:17 -0500
In-Reply-To: <1357350160.1678.3303.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Fri, 04 Jan 2013 17:42:40 -0800

> From: Eric Dumazet <edumazet@google.com>
 ...
> [PATCH v2 net-next] veth: avoid a NULL deref in veth_stats_one

Applied, thanks Eric.
