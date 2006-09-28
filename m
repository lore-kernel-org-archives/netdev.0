From: Horms <horms@verge.net.au>
Subject: Re: [patch 0/2] [IPVS]: Make sure ip_vs_ftp ports are valid (again)
Date: Thu, 28 Sep 2006 15:59:54 +0900
Message-ID: <20060928065952.GC22943@verge.net.au>
References: <20060920144457.533479580@yukiko.lab.ultramonkey.org> <20060927.225354.48396393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, wensong@linux-vs.org,
	ja@ssi.bg, jmack@wm7d.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:32203 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751654AbWI1HEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 03:04:30 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060927.225354.48396393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2006 at 10:53:54PM -0700, David Miller wrote:
> From: Horms <horms@verge.net.au>
> Date: Wed, 20 Sep 2006 23:44:57 +0900
> 
> > there are two patches floating around for this problem.
> > It seems that the first incarntation has been committed
> > to Linus's tree as 3f5af5b353ca36aca4f8a46e3da2172f669dbbbc.
> > 
> > This series of 2 patches reverses that change, and
> > adds the new, simpler, change in its place.
> 
> Both applied, thanks Simon.

Thanks

> If you think it's serious enough to submit for -stable, just
> let me know.

I regard this as a cosmetic change, so it can wait for 2.6.19.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

