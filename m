From: David Miller <davem@davemloft.net>
Subject: Re: problem with 'net: Partially allow skb destructors to be used
 on receive path'
Date: Tue, 23 Jun 2009 16:37:43 -0700 (PDT)
Message-ID: <20090623.163743.98163763.davem@davemloft.net>
References: <20090622122525.GA24481@gondor.apana.org.au>
	<4A3F8AC6.2070803@hartkopp.net>
	<20090622145642.GA31280@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44984
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753893AbZFWXhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 19:37:39 -0400
In-Reply-To: <20090622145642.GA31280@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 22 Jun 2009 22:56:42 +0800

> On Mon, Jun 22, 2009 at 03:44:38PM +0200, Oliver Hartkopp wrote:
>>
>> I tried to apply the patch on 2.6.30 also and only got some offsets (as expected).
> 
> Thanks for testing!
> 
>> Do you think, it's a good idea to queue this up for 2.6.30-stable?
> 
> If it's OK with Dave then it's OK with me.

I've applied Herbert's patch, thanks everyone!

I'll queue it up for -stable too.
