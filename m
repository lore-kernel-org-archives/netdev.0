From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix error in comment on
 net_device_ops::ndo_get_stats
Date: Tue, 15 Jun 2010 15:10:40 -0700 (PDT)
Message-ID: <20100615.151040.191416638.davem@davemloft.net>
References: <1276528781.2074.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751470Ab0FOWK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 18:10:29 -0400
In-Reply-To: <1276528781.2074.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 14 Jun 2010 16:19:41 +0100

> ndo_get_stats still returns struct net_device_stats *; there is
> no struct net_device_stats64.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

But, I am ignoring every single patch you submit from here on
out that lacks a proper "net-2.6" or "net-next-2.6" destination
tree indication in your Subject line.

I've asked this of you at least 3 times, and you seem content to just
ignore my request.  But that's OK, as I think you'll stop ignoring
me when it starts causing patches you care about to be dropped.

Thanks :-)
