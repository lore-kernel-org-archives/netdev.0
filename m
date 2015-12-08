From: Liberman Igal <Igal.Liberman@freescale.com>
Subject: RE: [v9, 3/6] fsl/fman: Add FMan MAC support
Date: Tue, 8 Dec 2015 11:20:28 +0000
Message-ID: <DM2PR03MB50977BE1FED436058110704E6080@DM2PR03MB509.namprd03.prod.outlook.com>
References: <1449127157-9400-1-git-send-email-igal.liberman@freescale.com>
	<1449127157-9400-4-git-send-email-igal.liberman@freescale.com>
 <20151203.152342.830757781812463540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151203.152342.830757781812463540.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Regards,
Igal Liberman

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, December 03, 2015 10:24 PM
> To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
> Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; linux-
> kernel@vger.kernel.org; Wood Scott-B07421 <scottwood@freescale.com>;
> Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>;
> pebolle@tiscali.nl; joakim.tjernlund@transmode.se; ppc@mindchasers.com;
> stephen@networkplumber.org
> Subject: Re: [v9, 3/6] fsl/fman: Add FMan MAC support
> 
> From: <igal.liberman@freescale.com>
> Date: Thu, 3 Dec 2015 09:19:14 +0200
> 
> > +static u32 crc_table[256] = {
> 
> No way.
> 
> We have every conceivable implementation of CRC calculations in the kernel
> already.  Use them.

OK, I will remove the private implementation of CRC calculation in the next submission. Thank you.

Igal
