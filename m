From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Fix error in comment on
 net_device_ops::ndo_get_stats
Date: Tue, 15 Jun 2010 23:24:03 +0100
Message-ID: <1276640643.14011.558.camel@localhost>
References: <1276528781.2074.0.camel@achroite.uk.solarflarecom.com>
	 <20100615.151040.191416638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17399 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab0FOWYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 18:24:08 -0400
In-Reply-To: <20100615.151040.191416638.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-15 at 15:10 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 14 Jun 2010 16:19:41 +0100
> 
> > ndo_get_stats still returns struct net_device_stats *; there is
> > no struct net_device_stats64.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Applied.
> 
> But, I am ignoring every single patch you submit from here on
> out that lacks a proper "net-2.6" or "net-next-2.6" destination
> tree indication in your Subject line.
> 
> I've asked this of you at least 3 times, and you seem content to just
> ignore my request.  But that's OK, as I think you'll stop ignoring
> me when it starts causing patches you care about to be dropped.
> 
> Thanks :-)

Sorry Dave, I thought net-next-2.6 was still the default and I only
needed to make it more obvious when I wanted patches to go to net-2.6.
I've added the suffix to my git configuration now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

