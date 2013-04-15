From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] inet: fix enforcing of fragment queue hash list depth
Date: Mon, 15 Apr 2013 19:43:37 +0200
Message-ID: <20130415174337.GC29378@order.stressinduktion.org>
References: <20130415142454.14020.18322.stgit@dragon> <20130415152637.GA29378@order.stressinduktion.org> <1366046186.11284.70.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44760 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282Ab3DORnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:43:39 -0400
Content-Disposition: inline
In-Reply-To: <1366046186.11284.70.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 07:16:26PM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 2013-04-15 at 17:26 +0200, Hannes Frederic Sowa wrote:
> 
> > I will have to play with this patch a bit. Perhaps I have some more insights
> > after that. :)
> 
> I would actually like to do/finish up this patch my self, as I have
> several patches in this code area.  But I would value your input :-)

No problem at all, I already thought so.
