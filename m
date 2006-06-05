From: Christoph Hellwig <hch@infradead.org>
Subject: Re: wireless (was Re: 2.6.18 -mm merge plans)
Date: Mon, 5 Jun 2006 09:54:51 +0100
Message-ID: <20060605085451.GA26766@infradead.org>
References: <20060604135011.decdc7c9.akpm@osdl.org> <20060605010636.GB17361@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36227 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750789AbWFEIyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 04:54:55 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20060605010636.GB17361@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 04, 2006 at 09:06:36PM -0400, Jeff Garzik wrote:
> On Sun, Jun 04, 2006 at 01:50:11PM -0700, Andrew Morton wrote:
> > acx1xx-wireless-driver.patch
> > fix-tiacx-on-alpha.patch
> > tiacx-fix-attribute-packed-warnings.patch
> > tiacx-pci-build-fix.patch
> > tiacx-ia64-fix.patch
> > 
> >   It is about time we did something with this large and presumably useful
> >   wireless driver.
> 
> I've never had technical objections to merging this, just AFAIK it had a
> highly questionable origin, namely being reverse-engineered in a
> non-clean-room environment that might leave Linux legally vulnerable.

As are at leasdt a fourth of linux drivers.  Andrew, please just go ahead
and merge it (I'll do another review ASAP).

Please don't let this reverse engineering idiocy hinder wireless driver
adoption, we're already falling far behind openbsd who are very successfull
reverse engineering lots of wireless chipsets.
