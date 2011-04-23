From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Sat, 23 Apr 2011 07:48:46 +0200
Message-ID: <20110423054846.GF23775@game.jcrosoft.org>
References: <87vczkmy94.fsf@macbook.be.48ers.dk>
 <AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com>
 <871v26m8tf.fsf@macbook.be.48ers.dk>
 <20110317085835.GC29758@n2100.arm.linux.org.uk>
 <87wrjyksnm.fsf@macbook.be.48ers.dk>
 <20110317093403.GA15396@pulham.picochip.com>
 <20110317215101.GC2927@pulham.picochip.com>
 <20110318154118.GQ29758@n2100.arm.linux.org.uk>
 <20110318154839.GB3393@pulham.picochip.com>
 <20110318155428.GA22087@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	"avictor.za@gmail.com" <avictor.za@gmail.com>,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:35440 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751538Ab1DWF57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2011 01:57:59 -0400
Content-Disposition: inline
In-Reply-To: <20110318155428.GA22087@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I happy to split the driver and arch updates, but I'm not sure that it 
> > can be done in such a way that platforms would build between the arch 
> > and driver merges.
> > 
> > > I'm also concious that this has become ready for potentially merging
> > > during the merge window, and therefore hasn't had previous exposure
> > > in linux-next, and so should wait until the next merge window.  I do
> > > feel that I'm going to be yelled at for saying that... but I'm sure
> > > I'll also be yelled at if I did take it.
> > 
> > I don't have any problem with waiting until the next merge window, and 
> > to be honest I'd like see these patches have some time in next as I 
> > can't test them on devices with a MACB.
> 
> Okay, that sounds like a very good reason to wait until Nicolas can
> review them and provide an ack.
David Russell If you don't mind I'll apply it on at91 tree as we prepare other
huge update on mach-at91

Best Regards,
J.
