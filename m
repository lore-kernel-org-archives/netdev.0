From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/2] net: dsa: introduce MICREL KSZ8893MQL/BL ethernet switch chip support
Date: Wed, 21 Jul 2010 17:36:05 +0200
Message-ID: <20100721153605.GO21121@mail.wantstofly.org>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org> <1279719442-10174-2-git-send-email-vapier@gentoo.org> <20100721151608.GM21121@mail.wantstofly.org> <1279726393.2452.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Karl Beldan <karl.beldan@gmail.com>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:39010 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab0GUPgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 11:36:06 -0400
Content-Disposition: inline
In-Reply-To: <1279726393.2452.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 05:33:13PM +0200, Eric Dumazet wrote:

> > > +#define pr_fmt(fmt) "ksz8893m: " fmt
> > 
> > This has no users.
> 
> Dont tell this to Joe Perches ;)
> 
> It is used by all pr_err() friends

Oops, my bad!
