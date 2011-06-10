From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: DM9000: Add support for byte EEPROM access
Date: Fri, 10 Jun 2011 13:24:02 +0100
Message-ID: <1307708642.22348.590.camel@localhost>
References: <1307703032-20349-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:14593 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011Ab1FJMYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 08:24:05 -0400
In-Reply-To: <1307703032-20349-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-10 at 11:50 +0100, Mark Brown wrote:
> From: Ben Dooks <ben-linux@fluff.org>
> 
> Given many versions of ethtool's reluctance to do anything other than
> byte accesses to the EEPROM interface, it is easier to update the driver
> to support byte accesses so that all the ethtool versions that have been
> observed in Debian can write the EEPROM.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

