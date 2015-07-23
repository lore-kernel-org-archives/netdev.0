From: Liberman Igal <Igal.Liberman@freescale.com>
Subject: RE: [v3, 2/9] fsl/fman: Add the FMan port FLIB
Date: Thu, 23 Jul 2015 12:48:10 +0000
Message-ID: <DM2PR03MB383B0007660E892B81B5ADAE6820@DM2PR03MB383.namprd03.prod.outlook.com>
References: <1437564108-16490-1-git-send-email-igal.liberman@freescale.com>
 <20150722095553.4cd028d1@urahara>
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
	"ppc@mindchasers.com" <ppc@mindchasers.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150722095553.4cd028d1@urahara>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Regards,
Igal Liberman.

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, July 22, 2015 7:56 PM
> To: Liberman Igal-B31950
> Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; linux-
> kernel@vger.kernel.org; Wood Scott-B07421; Bucur Madalin-Cristian-B32716;
> pebolle@tiscali.nl; joakim.tjernlund@transmode.se; ppc@mindchasers.com
> Subject: Re: [v3, 2/9] fsl/fman: Add the FMan port FLIB
> 
> On Wed, 22 Jul 2015 14:21:48 +0300
> <igal.liberman@freescale.com> wrote:
> 
> > diff --git a/drivers/net/ethernet/freescale/fman/Kconfig
> b/drivers/net/ethernet/freescale/fman/Kconfig
> > index 8aeae29..af42c3a 100644
> > --- a/drivers/net/ethernet/freescale/fman/Kconfig
> > +++ b/drivers/net/ethernet/freescale/fman/Kconfig
> > @@ -5,3 +5,4 @@ config FSL_FMAN
> >  	help
> >  		Freescale Data-Path Acceleration Architecture Frame
> Manager
> >  		(FMan) support
> > +
> 
> Bogus blank line introduced at end of file?
> Why was this not in patch 1?

It was added during the patch splitting.
I'll fix that in the next submission, thank you for noticing.

Igal.
