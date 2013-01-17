From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH] ipv6: do not create neighbor entries for local delivery
Date: Thu, 17 Jan 2013 09:17:40 -0200
Message-ID: <50F7DDD4.7000503@redhat.com>
References: <50F6ABCA.4020804@redhat.com> <20130116.162813.1734293658687337225.davem@davemloft.net>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944Ab3AQLRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 06:17:44 -0500
In-Reply-To: <20130116.162813.1734293658687337225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 16-01-2013 19:28, David Miller escreveu:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Date: Wed, 16 Jan 2013 11:31:54 -0200
>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index
>> 7c34c01b515b7ac370f8021ba6f5ec4c654e9e41..b63e33bcbdfbc1bd78af0b98ffc2d211805214ea
>> 100644
>
> Patch corrupted by your email client.

Doh, really sorry about that.

> Note also that YOSHIFUJI Hideaki's patches to remove the cached neighbour
> entirely from ipv6 routes will have the same effect, so your patch won't
> be needed.

Yes but seems it needs some time yet. Mind if I submit it again (right 
this time)?

Thanks,
Marcelo.
