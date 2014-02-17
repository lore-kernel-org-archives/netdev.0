From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast
 address
Date: Mon, 17 Feb 2014 00:15:45 -0500 (EST)
Message-ID: <20140217.001545.981758741332832466.davem@davemloft.net>
References: <1392212332-10463-1-git-send-email-fx.lebail@yahoo.com>
	<20140213001624.GJ11150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fx.lebail@yahoo.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	christoph.paasch@uclouvain.be, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaBQFPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:15:47 -0500
In-Reply-To: <20140213001624.GJ11150@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 13 Feb 2014 01:16:24 +0100

> [added Cc list from old thread]
> 
> On Wed, Feb 12, 2014 at 02:38:51PM +0100, Francois-Xavier Le Bail wrote:
>> - Use ipv6_chk_acast_addr_src() in inet6_bind().
>> 
>> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> 
> I would agree with the change but would like to see some people from the old
> thread about this change to agree with it, too.

I hear crickets... instead of other reviews :-)
