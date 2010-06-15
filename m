From: David Miller <davem@davemloft.net>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Tue, 15 Jun 2010 11:39:40 -0700 (PDT)
Message-ID: <20100615.113940.245399246.davem@davemloft.net>
References: <20100610145915.721a86b7@nehalam>
	<20100610224839.GA22469@gondor.apana.org.au>
	<20100611021142.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757391Ab0FOSja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:39:30 -0400
In-Reply-To: <20100611021142.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 11 Jun 2010 12:11:42 +1000

> On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
>> On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrote:
>> >
>> > Okay, then add a comment where in_irq is used?
>> 
>> Actually let me put it into a wrapper.  I'll respin the patches.
> 
> OK here is a repost.  And this time it really is 8 patches :)
> I've tested it lightly.

All applied to net-next-2.6, thanks Herbert.
