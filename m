From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] tilegx network driver: initial support
Date: Thu, 24 May 2012 00:31:48 -0400 (EDT)
Message-ID: <20120524.003148.700603156196416506.davem@davemloft.net>
References: <201205201636.q4KGaoA3003845@farm-0027.internal.tilera.com>
	<20120520.165546.1211013675964130504.davem@davemloft.net>
	<201205240115.q4O1FwqG006336@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201205240115.q4O1FwqG006336@lab-41.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Wed, 23 May 2012 16:42:03 -0400

> + * FIXME (bug 11489): add support for IPv6.
 ...
> +	 * FIXME (bug# 11479): We should stop queues when they're full.
 ...

Mentioning bug numbers in the driver source is not appropriate.

This second problem looks extremely serious, rather than some minor
issue to look into at some time in the future.
