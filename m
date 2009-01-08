From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] ipv6: Add GRO support
Date: Thu, 08 Jan 2009 10:41:37 -0800 (PST)
Message-ID: <20090108.104137.182749410.davem@davemloft.net>
References: <20090107031404.GA16827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38320
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755662AbZAHSlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:41:36 -0500
In-Reply-To: <20090107031404.GA16827@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 7 Jan 2009 14:14:04 +1100

> ipv6: Add GRO support
> 
> This patch adds GRO support for IPv6.  IPv6 GRO supports extension
> headers in the same way as GSO (by using the same infrastructure).
> It's also simpler compared to IPv4 since we no longer have to worry
> about fragmentation attributes or header checksums.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
