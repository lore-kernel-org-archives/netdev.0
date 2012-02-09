From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: Re: drivers/net/phy/phy.c issue
Date: Thu, 9 Feb 2012 05:06:25 -0800
Message-ID: <20120209130625.GA27224@ericsson.com>
References: <CACW_hTY41xZV6d0W2Z2kRfKOfa+RSQ-A-BoZsZwNXSQmeF_6Gg@mail.gmail.com>
 <1328729420.2261.329.camel@groeck-laptop>
 <CACW_hTbLd3kbuwJy9U2ZGDi3ypD-+KsecjYhku7jwQgFPaRqhg@mail.gmail.com>
 <20120208150548.32643cmtaxtymzok@67.228.131.195>
 <CACW_hTad_DtwR7FqqOjzvCOzbdj1PcSCEyUpg6d-G5VtDi3wbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "guenter@roeck-us.net" <guenter@roeck-us.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"macro@linux-mips.org" <macro@linux-mips.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Frans Meulenbroeks <fransmeulenbroeks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACW_hTad_DtwR7FqqOjzvCOzbdj1PcSCEyUpg6d-G5VtDi3wbQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 09, 2012 at 03:12:01AM -0500, Frans Meulenbroeks wrote:
> 2012/2/8  <guenter@roeck-us.net>:
> > Quoting "Frans Meulenbroeks" <fransmeulenbroeks@gmail.com>:
> >
> 
> [...]
> >> Apologies, but I cannot test on a git head kernel.
> >>
> >> And wrt the question of Andy in the subsequent reply.
> >>
> >> Hw is a Freescale MPC8313. This is a Gianfar. Is that the info you wanted?
> >>
> > This is the MAC. Andy was asking for the PHY chip.
> >
> Sorry yes.
> The mac is a Marvell 88e1111bab

This time you mean the PHY is Marvell 88e1111bab, not the MAC. Looks like
you are getting confused ;).

Guenter
