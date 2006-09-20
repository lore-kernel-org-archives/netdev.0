From: Horms <horms@verge.net.au>
Subject: Re: ipvs locahost client patch for 2.6?
Date: Wed, 20 Sep 2006 23:57:53 +0900 (JST)
Message-ID: <20060920145753.B1B253403B@koto.vergenet.net>
References: <20060810161838.GD5088@britestream.com>
Cc: netdev@vger.kernel.org, horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:8919 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751589AbWITO5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 10:57:54 -0400
To: Ryan Nowakowski <ryan@britestream.com>
In-Reply-To: <20060810161838.GD5088@britestream.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Aug 2006 01:18:38, Ryan Nowakowski wrote:
> I found this patch for 2.4 that allows the host running ipvs to act
> as it's own client via loopback connection.  Does anyone have a similar
> patch for 2.6?

Not that I am aware of, though that kind of approach may well work for
2.6 with little effort.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

