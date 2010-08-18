From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2.6.37?] drivers/net/pcmcia: Use pr_<level>
 and netdev_<level>
Date: Wed, 18 Aug 2010 14:27:19 -0700 (PDT)
Message-ID: <20100818.142719.115921595.davem@davemloft.net>
References: <20100809153410.GA27238@comet.dominikbrodowski.net>
	<1281651771.15486.55.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@dominikbrodowski.net, w.sang@pengutronix.de,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754386Ab0HRV1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:27:00 -0400
In-Reply-To: <1281651771.15486.55.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 12 Aug 2010 15:22:51 -0700

> On Mon, 2010-08-09 at 17:34 +0200, Dominik Brodowski wrote:
>> look good from a PCMCIA point of view, therefore:
>> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> 
> If PCMCIA is still being looked after, then here's
> another for you, maybe for 2.6.37.
> 
> Use the more descriptive logging message styles.
> 
> There are whitespace/indentation errors in the original
> sources that these changes do not modify, so checkpatch
> errors were cheerfully ignored.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
