From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 11:36:47 -0700
Message-ID: <1154630207.3117.17.camel@rh4>
References: <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:18194 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030183AbWHCSfM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 14:35:12 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 20:00 +1000, Herbert Xu wrote:
> Theodore Tso <tytso@mit.edu> wrote:
> > 
> > I'm sending this on mostly because it was a bit of a pain to track down,
> > and hopefully it will save time if anyone else hits this while playing
> > with the -rt kernel.  It is NOT the right way to fix things, so please
> > don't even think of applying this patch (unless you need it, in your own
> > local tree :-).
> > 
> > One of these days when we have time to breath we'll look into fixing
> > this the right way, if someone doesn't beat us to it first.  :-)
> 
Ted, what tg3 hardware is having this timer related problem?  Can you
send me the tg3 probing output?

