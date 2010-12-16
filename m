From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix IPv6 queries for bridge multicast snooping
Date: Thu, 16 Dec 2010 14:17:50 -0800 (PST)
Message-ID: <20101216.141750.200361016.davem@davemloft.net>
References: <1292352136.4720.11.camel@IBM-1B506CFC885>
	<20101215010050.GB20448@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, davem@davemloft.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756426Ab0LPWRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:17:21 -0500
In-Reply-To: <20101215010050.GB20448@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 15 Dec 2010 09:00:50 +0800

> On Tue, Dec 14, 2010 at 10:42:16AM -0800, David L Stevens wrote:
>> This patch fixes a missing ntohs() for bridge IPv6 multicast snooping.
>> 
>> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I had wanted to fix this but forgot :)

Applied and queued up for -stable, thanks!
