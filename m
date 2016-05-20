From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "phy: add support for a reset-gpio
 specification"
Date: Fri, 20 May 2016 17:57:26 -0400 (EDT)
Message-ID: <20160520.175726.1939152379956607230.davem@davemloft.net>
References: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, linux@roeck-us.net,
	f.fainelli@gmail.com, netdev@vger.kernel.org
To: fabio.estevam@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbcETV53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 17:57:29 -0400
In-Reply-To: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>
Date: Wed, 18 May 2016 13:05:00 -0300

> Commit da47b4572056 ("phy: add support for a reset-gpio specification")
> causes the following xtensa qemu crash according to Guenter Roeck:
 ...
> This reverts commit da47b4572056487fd7941c26f73b3e8815ff712a.
> 
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Applied, thanks.
