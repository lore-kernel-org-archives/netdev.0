From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [GIT PULL] Support for Cadence GEM in the MACB driver
Date: Tue, 22 Nov 2011 15:59:22 +0100
Message-ID: <20111122145922.GM21480@game.jcrosoft.org>
References: <20111121100020.GB7314@totoro>
 <20111122100032.GL21480@game.jcrosoft.org>
 <20111122102039.GB8872@totoro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	davem@davemloft.net
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo2.mail-out.ovh.net ([178.32.228.2]:33017 "EHLO
	mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641Ab1KVPBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:01:53 -0500
Received: from mail190.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id E41C5DC95AB
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 16:08:12 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20111122102039.GB8872@totoro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10:20 Tue 22 Nov     , Jamie Iles wrote:
> Hi Jean-Christophe,
> 
> On Tue, Nov 22, 2011 at 11:00:32AM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 10:00 Mon 21 Nov     , Jamie Iles wrote:
> > > Hi Arnd,
> > > 
> > > Please consider pulling the patches to add support for Cadence GEM to 
> > > the MACB driver.  These have been ready to go for a little while but got 
> > > held up with the rename of Ethernet drivers in the last merge window.  
> > > It would be great if we can get some exposure in -next for a little 
> > > while before the next merge window.
> > > 
> > > Thanks,
> > > 
> > > Jamie
> > > 
> > > The following changes since commit cfcfc9eca2bcbd26a8e206baeb005b055dbf8e37:
> > > 
> > >   Linux 3.2-rc2 (2011-11-15 15:02:59 -0200)
> > > 
> > > are available in the git repository at:
> > >   git://github.com/jamieiles/linux-2.6-ji.git macb-gem
> > Arnd please wait
> > 
> > please update his patch
> > 
> > "at91: provide macb clks with "pclk" and "hclk" name"
> > 
> > with the version I send to the ML
> 
> Is that a patch that you've already posted or will be posting?
http://patchwork.ozlabs.org/patch/109265/

but please specify the device too

Best Regards,
J.
