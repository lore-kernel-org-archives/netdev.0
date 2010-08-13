From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH net-next 2.6.37?] drivers/net/pcmcia: Use pr_<level>
 and netdev_<level>
Date: Fri, 13 Aug 2010 20:51:06 +0200
Message-ID: <20100813185106.GA5853@comet.dominikbrodowski.net>
References: <20100809153410.GA27238@comet.dominikbrodowski.net>
 <1281651771.15486.55.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfram Sang <w.sang@pengutronix.de>, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:52705 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758523Ab0HMTZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Aug 2010 15:25:14 -0400
Content-Disposition: inline
In-Reply-To: <1281651771.15486.55.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 12, 2010 at 03:22:51PM -0700, Joe Perches wrote:
> On Mon, 2010-08-09 at 17:34 +0200, Dominik Brodowski wrote:
> > look good from a PCMCIA point of view, therefore:
> > Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> 
> If PCMCIA is still being looked after, then here's
> another for you, maybe for 2.6.37.

Well, as this is netdev-related, shouldn't it go in via netdev instead?
David?

> Use the more descriptive logging message styles.
> 
> There are whitespace/indentation errors in the original
> sources that these changes do not modify, so checkpatch
> errors were cheerfully ignored.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
Acked-by / Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

