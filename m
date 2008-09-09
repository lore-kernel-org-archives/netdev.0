From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.27
Date: Mon, 08 Sep 2008 21:30:50 -0700 (PDT)
Message-ID: <20080908.213050.176981752.davem@davemloft.net>
References: <0E7517ED-A2C3-4DFB-9733-0DAEA82F3815@holtmann.org>
	<20080908.194209.111481398.davem@davemloft.net>
	<1220934481.11655.32.camel@californication>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45218
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbYIIEa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:30:56 -0400
In-Reply-To: <1220934481.11655.32.camel@californication>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 09 Sep 2008 06:28:01 +0200

> > > The number of users are still limited to a few people actually
> > > testing with 2.1 hardware. These are mainly people working on 2.1
> > > enabled products. However with the new MacBooks and the EeePC 901 we
> > > do have devices with Bluetooth 2.1 chips available for everybody.
> > >
> > > This is clearly an oversight on my hand when developing the initial
> > > Simple Pairing patches that I submitted for 2.6.27-rc1 and I only
> > > found it when we tested against the official Bluetooth 2.1 test
> > > system.
> > 
> > This is the core issue, if it regresses from 2.6.26, and if so you should
> > mention that somewhere.  Best would be in the commit message itself.
> > 
> > Then I wouldn't have had to ask you anything.
> > 
> > But instead you're having to describe it for me here in this email, which
> > nobody can see when scanning the GIT commit messages, so it essentially
> > might as well not even exist.
> 
> I thought that I did describe this properly in the commit message, but
> it could also only be clear to me. Do you want me to fix up the commit
> message with more details?

Where in your commit message did you specifically state and explain
that this problem is specifically a regression against 2.6.26?  I didn't
catch that part.


