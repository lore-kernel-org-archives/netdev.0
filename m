From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: add get permanent address option (v2)
Date: Tue, 16 Nov 2010 23:12:56 +0000
Message-ID: <1289949176.30433.9.camel@localhost>
References: <20101018114139.71073a40@nehalam>
	 <1287431541.2252.556.camel@achroite.uk.solarflarecom.com>
	 <20101018131104.02681d60@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33028 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932466Ab0KPXM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 18:12:59 -0500
In-Reply-To: <20101018131104.02681d60@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 13:11 -0700, Stephen Hemminger wrote:
> Add command level support for showing permanent address.
> The ioctl has been around for a long time but there was
> no option to display it.
> 
> Note: MAX_ADDR_LEN is defined in netdevice.h but including
> netdevice.h leads to multiple definition errors with if.h.
[...]

Applied, along with the fix-up noted by Joe Perches.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

