From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/tcp_ipv6.c: Use compressed IPv6 address
Date: Fri, 08 Jan 2010 01:00:04 -0800 (PST)
Message-ID: <20100108.010004.261893877.davem@davemloft.net>
References: <1262476301.1932.90.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54442
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750863Ab0AHI7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:59:55 -0500
In-Reply-To: <1262476301.1932.90.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 02 Jan 2010 15:51:41 -0800

> Use "[compressed ipv6]:port" form suggested by:
> http://tools.ietf.org/id/draft-ietf-6man-text-addr-representation-03.txt
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next-2.6, thanks Joe.
