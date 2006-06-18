From: "Jason operater" <bofh1234@hotmail.com>
Subject: Re: recommend a network card
Date: Sun, 18 Jun 2006 11:13:38 -0500
Message-ID: <BAY101-F260B4F2FEC93FE61A81BF4C8810@phx.gbl>
References: <200606181748.55398.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay101-f26.bay101.hotmail.com ([64.4.56.36]:56775 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S932105AbWFRQNl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 12:13:41 -0400
In-Reply-To: <200606181748.55398.mb@bu3sch.de>
To: mb@bu3sch.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Michael Buesch <mb@bu3sch.de>
>To: "bastard operater" <bofh1234@hotmail.com>
>CC: netdev@vger.kernel.org
>Subject: Re: recommend a network card
>Date: Sun, 18 Jun 2006 17:48:55 +0200
>
>On Sunday 18 June 2006 17:28, bastard operater wrote:
> > >I never had a malfunctioning NIC. What does it look like?
> > >Broken packages?
> >
> > It loses its network connection (the systems says the card is unplugged) 
>for
> > a second or two and then the connection comes back.  Sometimes the
> > connection just stops working  and I have to restart the network 
>service.
>
>uh, oh. Interresting.
>Sure it is not a software bug in PCI hotplug or something?
>(or something accidentally poking with fakephp)

It worked great for the first 6 years.  Only in the last year has it become 
unstable.  There have been no driver changes since 2001.  My motherboard (7 
years old, tyan tiger S1832D) does not support hotplug.  I moved it to 
another PC and it still has problems.

>I would test the card in another machine, before throwing it away.
>
> > > > I am in the market for a new NIC.  The card has to work on Linux
> > >(natively)
> > > > and windows.  I thought I would ask the experts if you have any
> > > > recommendations for a good 100MB PCI card?
> > >
> > >I have mostly RTL based cards (ranging from 10 to 1000 mbit).
> > >No problems so far. (But also no problem with my 3c905 since
> > >quite some time ;) )
> >
> > How can I tell which cards use which chipset?
>
>Look at the chip ;)
>One of my cards (100mbit) has a chip with the string
>RTL8139D
>printed on it.
>There's usually only one or two chips on the card. You can't miss it.
>It's the chip, which is connected directly to the PCI pins.

I don't have x-ray vision so I can't see through cardboard.  :)  Can you 
recommand a specific card or groups of cards?

>btw: This is not really the right list to ask such questions,
>      as it is not development related, but well... :)

Yeah, I know.  I wanted to ask the experts.  I don't want to buy a cheap 
network card only to get it home and find it uses 75% of CPU during 
transfers.  Or even worse it is not supported by Linux.  If you know of a 
linux certified hardware list I would love to hear about it.

Thanks,
Jason


