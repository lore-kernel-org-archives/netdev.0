From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Tue, 02 Apr 2013 17:23:22 +0200
Message-ID: <1364916202.3232.311.camel@localhost>
References: <20130327155238.15203.6688.stgit@dragon>
	 <20130327155601.15203.25289.stgit@dragon>
	 <1364405159.15753.26.camel@edumazet-glaptop>
	 <20130328185721.GA20223@order.stressinduktion.org>
	 <1364502164.15753.56.camel@edumazet-glaptop>
	 <20130328233002.GC20223@order.stressinduktion.org>
	 <1364513982.15753.57.camel@edumazet-glaptop>
	 <20130329003308.GD20223@order.stressinduktion.org>
	 <1364583693.3232.257.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760543Ab3DBPXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:23:39 -0400
In-Reply-To: <1364583693.3232.257.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 20:01 +0100, Jesper Dangaard Brouer wrote:

> I'm officially back from vacation Tuesday, and I'll repost then (after
> testing it on my 10G testlab).

Argh- just deleted a long mail with a lot of test results, showing
strange performance results ... as I just realized that /boot ran dry
during my testing procedure, thus invalidating all the test I spend most
of the day performing, argh!

--Jesper
