From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DM9000: Allow randomised ethernet address
Date: Mon, 28 Feb 2011 12:42:52 -0800 (PST)
Message-ID: <20110228.124252.15241159.davem@davemloft.net>
References: <1298553432-30240-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	patches@opensource.wolfsonmicro.com, ben-linux@fluff.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754515Ab1B1UmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:42:15 -0500
In-Reply-To: <1298553432-30240-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Thu, 24 Feb 2011 13:17:12 +0000

> From: Ben Dooks <ben-linux@fluff.org>
> 
> Allow randomised ethernet address if the device does not have a valid
> EEPROM or pre-set MAC address.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Applied.
