From: Horms <horms@verge.net.au>
Subject: Re: [rfc][patch] ipvs: use proper timeout instead of fixed value
Date: Sun, 7 May 2006 13:38:40 +0900
Message-ID: <20060507043838.GF8374@verge.net.au>
References: <20060504201116.GA24394@gospo.rdu.redhat.com> <20060505004754.GA6943@verge.net.au> <20060505025111.GA29142@gospo.rdu.redhat.com> <20060505032052.GY32328@verge.net.au> <20060505185726.GB24394@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:9930 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1750949AbWEGEuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 May 2006 00:50:02 -0400
To: Andy Gospodarek <andy@greyhouse.net>
Content-Disposition: inline
In-Reply-To: <20060505185726.GB24394@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 05, 2006 at 02:57:26PM -0400, Andy Gospodarek wrote:
> On Fri, May 05, 2006 at 12:20:54PM +0900, Horms wrote:
> > 
> > Sorry, I missunderstood your patch completely the first time around.
> > Yes I think this is an excellent idea. Assuming its tested and works
> > I'm happy to sign off on it and prod DaveM.
> 
> Horms,
> 
> I'll get a setup together and post results when I have them.

I was thinking that it would be nice if the timeout could be sent over
the wire, though that might bring in some compatibility issues,
and thus your approach might be the best idea.

-- 
Horms                                           http://www.vergenet.net/~horms/

