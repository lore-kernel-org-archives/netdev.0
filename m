From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Wed, 28 Jun 2006 09:56:00 -0500
Message-ID: <1151506560.13315.3.camel@trinity.ogc.int>
References: <20060628.000715.95062023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rolandd@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:3894 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S932559AbWF1OuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 10:50:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060628.000715.95062023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 00:07 -0700, David Miller wrote:
> Roland, there is no way in the world we would have let support for
> RDMA into the kernel tree had we seen and reviewed it on netdev.  I've
> discussed this with Andrew Morton, and we'd like you to please revert
> all of the RDMA code from Linus's tree immedialtely.
> 
> Folks are well aware how against RDMA and TOE type schemes the Linux
> networking developers are.  So the fact that none of these RDMA
> changes went up for review on netdev strikes me as just a little bit
> more than suspicious.
> 
> Please do not do this again, thank you.

I believe Roland is on vacation (they just had a baby..). 

It is my belief that everything that Roland submitted went through both
netdev and lklm reviews. 


> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

