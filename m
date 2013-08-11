From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2 net-next] af_unix: improve STREAM behavior with fragmented memory
Date: Sun, 11 Aug 2013 16:37:15 +0200
Message-ID: <20130811143715.GA3699@order.stressinduktion.org>
References: <1375997852.4004.130.camel@edumazet-glaptop> <20130811140605.GA5666@order.stressinduktion.org> <1376231553.3291.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	David Rientjes <rientjes@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44706 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab3HKOhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 10:37:17 -0400
Content-Disposition: inline
In-Reply-To: <1376231553.3291.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 11, 2013 at 07:32:33AM -0700, Eric Dumazet wrote:
> On Sun, 2013-08-11 at 16:06 +0200, Hannes Frederic Sowa wrote:
> 
> > I am sorry to report that I had to revert both these patches to have a working
> > systemd again.
> 
> Hi Hannes
> 
> If you revert only the second patch, the problem is still there, right ?

Exactly, only reverting 2/2 did not help.

Thanks,

  Hannes
