From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Sun, 19 Jun 2011 23:01:48 -0700
Message-ID: <1308549708.13032.14.camel@Joe-Laptop>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
	 <1308536729.22851.42.camel@jtkirshe-mobl>
	 <alpine.LNX.2.01.1106200717100.10183@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3095 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902Ab1FTGBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 02:01:50 -0400
In-Reply-To: <alpine.LNX.2.01.1106200717100.10183@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 07:23 +0200, Jan Engelhardt wrote:
> What's next, directory naming by Windows-originating coding styles -
> "Drivers/Networking/Ethernet/Packet Engines/"?
> >> And things maybe not spelled out
> >>         ixp2000 might just be ixp (what not intel?:)

Using embedded spaces is a poor choice.

> I don't understand your logic of doing pkteng -> packetengines

As demonstrated, it's too easy to typo
pkteng as pktgen.

> and ixp2000 -> ixp at the same time. I was quite thankful that
> Linux's driver names were not (always) TLAs like in OpenBSD.

The (what not intel?:) was just teasing.
I think ixp is sufficient.

I never thought of ixp2000 as the family
for the 2400 and 2800/2850.

Castine maybe, ixp2xxx maybe.
ixp2000?  Never heard of it.

Though maybe ixp would be confused for
those ixp4xx and maybe even the original
Digital/Intel ixp1200 parts too.

'course all of this is 10 years old now
and kind of pointless.

cheers, Joe

