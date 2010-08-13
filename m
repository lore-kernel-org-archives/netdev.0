From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: MAINTAINERS: PCMCIA SUBSYSTEM: Should F: drivers/net/pcmcia/
 be added?
Date: Fri, 13 Aug 2010 20:52:16 +0200
Message-ID: <20100813185216.GB5853@comet.dominikbrodowski.net>
References: <20100809153410.GA27238@comet.dominikbrodowski.net>
 <1281651771.15486.55.camel@Joe-Laptop>
 <1281653272.15486.62.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfram Sang <w.sang@pengutronix.de>, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:52702 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755485Ab0HMTZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Aug 2010 15:25:14 -0400
Content-Disposition: inline
In-Reply-To: <1281653272.15486.62.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

On Thu, Aug 12, 2010 at 03:47:52PM -0700, Joe Perches wrote:
> On Thu, 2010-08-12 at 15:22 -0700, Joe Perches wrote:
> > On Mon, 2010-08-09 at 17:34 +0200, Dominik Brodowski wrote:
> > > look good from a PCMCIA point of view, therefore:
> > > Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> 
> There's no maintainer entry for directory drivers/net/pcmcia/
> 
> Should
> 
> F:	drivers/net/pcmcia/
> 
> be added to the existing PCMCIA SUBSYSTEM entry?

in my opinion, no -- this entry is mostly about the PCMCIA core, not about
specific drivers, same as the PCI bus guys aren't maintaining each and every
PCI driver...

Best,
	Dominik
