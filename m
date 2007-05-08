From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Tue, 8 May 2007 13:48:11 +0200
Message-ID: <20070508114811.GB32146@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <20070507175213.GU23611@tweety> <m3y7k08kvf.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Michael-Luke Jones <mlj28@cam.ac.uk>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King <rmk@arm.linux.org.uk>,
	Jeff Garzik <jeff@garzik.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:49968 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967340AbXEHLsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 07:48:15 -0400
Content-Disposition: inline
In-Reply-To: <m3y7k08kvf.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 10:00:20PM +0200, Krzysztof Halasa wrote:

> > - the NPE can also be used as DMA engine and for crypto operations.
> >   Both are not network related.
> >   Additionally, the NPE is not only ixp4xx related, but is
> >   also used in IXP23xx CPUs, so it could be placed in
> >   arch/arm/common or arch/arm/xscale ?
> >
> > - The MAC is used on IXP23xx, too. So the drivers for
> >   both CPU familys only differ in the way they exchange
> >   network packets between the NPE and the kernel.
> 
> Hmm... perhaps someone have a spare device with such IXP23xx
> and wants to make it a donation for science? :-)

I have a couple of ixp23xx boards at home, but I'm not sure whether I
can give them away.  I can give you remote access to them, though.
