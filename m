From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Thu, 14 Mar 2013 13:45:07 +0100
Message-ID: <20130314124507.GB27559@order.stressinduktion.org>
References: <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop> <20130313012715.GE14801@order.stressinduktion.org> <1363152568.13690.35.camel@edumazet-glaptop> <20130314013702.GA4129@order.stressinduktion.org> <1363245040.14913.11.camel@localhost> <20130314072341.GC4129@order.stressinduktion.org> <20130314072839.GD4129@order.stressinduktion.org> <1363252690.14913.42.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35012 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757656Ab3CNMpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 08:45:08 -0400
Content-Disposition: inline
In-Reply-To: <1363252690.14913.42.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 14, 2013 at 10:18:10AM +0100, Jesper Dangaard Brouer wrote:
> I will start working on this as soon as Netfilter Workshop is over and I
> have recovered from organizing this event.  DaveM told me I needed to
> finish my frag patches first, before I could implement all the other
> cool ideas we have come up with during the workshop ;-)

Yeah, I have had a look at your patches, looks promising. Definitely worth
that you get some pressure to finish them. :)

> But I don't know if my frag changes can make v3.9, maybe v3.10 is more
> realistic?  In which case we should use your patch to close this problem
> on v3.9 IMHO.

Sounds good.
