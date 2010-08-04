From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 1/2] ethtool: Use inet_aton() to parse IPv4
 addresses for RX n-tuple control
Date: Wed, 04 Aug 2010 21:51:08 +0100
Message-ID: <1280955068.2089.4.camel@achroite.uk.solarflarecom.com>
References: <1279825899.2104.28.camel@achroite.uk.solarflarecom.com>
	 <4C59CF65.2060801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6641 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934580Ab0HDUvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 16:51:11 -0400
In-Reply-To: <4C59CF65.2060801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-04 at 16:36 -0400, Jeff Garzik wrote:
> FYI, I'm about to roll a new ethtool release for kernel 2.6.35.  Are 
> these two patches the only outstanding ones?  (they look good, will be 
> applied)

Yes, those are the only ones.

> P.S.  The maintainer address is jgarzik@pobox.com, my standard kernel 
> address.  jgarzik@redhat.com has a much higher latency, as it doesn't 
> get used very much.

Sorry about that.  I've changed my git-format-patch config accordingly.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

