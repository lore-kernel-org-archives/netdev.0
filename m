From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet_cs: Use proper netdev_*-printouts
Date: Tue, 17 Aug 2010 02:34:45 -0700 (PDT)
Message-ID: <20100817.023445.226798725.davem@davemloft.net>
References: <1281270725-25282-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux@dominikbrodowski.net, joe@perches.com
To: w.sang@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932160Ab0HQJe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:34:27 -0400
In-Reply-To: <1281270725-25282-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>
Date: Sun,  8 Aug 2010 14:32:05 +0200

> To prevent broken messages like:
> 
> [  204.024291] eth%d: pcnet_reset_8390() did not complete.
> 
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>

Applied.
