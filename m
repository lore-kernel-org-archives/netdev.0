From: Simon Kirby <sim@netnation.com>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Tue, 13 Mar 2012 17:36:27 -0700
Message-ID: <20120314003627.GC10358@hostway.ca>
References: <20120313072643.GA32306@hostway.ca> <CADVnQynM5F=B60-7AMFHn0A9g-jvcBzo+dSg-C0isDBo_UMyjw@mail.gmail.com> <1331660251.4449.24.camel@edumazet-glaptop> <20120313.155906.1275225317793926230.davem@davemloft.net> <1331681457.4449.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:34766 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757591Ab2CNAg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 20:36:29 -0400
Content-Disposition: inline
In-Reply-To: <1331681457.4449.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 13, 2012 at 04:30:57PM -0700, Eric Dumazet wrote:

> On Tue, 2012-03-13 at 15:59 -0700, David Miller wrote:
> 
> > The syncookie regression fix isn't even pushed to Linus's tree yet,
> > and once it's there it still needs to cook for a few more days before
> > I'm willing to sent it to -stable.
> 
> Yeah, discussion diverged from tcp syncookie to other stuff (tcp at
> least ;) )

Yes, sorry, at first I thought it might be related. Anyway, the syncookie
fix is cooking in production(tm) for us, and working well. Thanks,

Simon-
