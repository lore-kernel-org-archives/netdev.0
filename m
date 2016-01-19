From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] MAINTAINERS: Update mailing list for Renesas SoC
 Development
Date: Tue, 19 Jan 2016 09:18:16 +0900
Message-ID: <20160119001815.GA14224@verge.net.au>
References: <1453079073-30937-1-git-send-email-horms+renesas@verge.net.au>
 <CAMuHMdXF8QnKsLOYFnT7Rje5G9_7Xr0NesO2SKEkWSivKQYkbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-renesas-soc@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Linux Media Mailing List <linux-media@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	Magnus Damm <magnus.damm@gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdXF8QnKsLOYFnT7Rje5G9_7Xr0NesO2SKEkWSivKQYkbA@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 18, 2016 at 09:09:29AM +0100, Geert Uytterhoeven wrote:
> CC linux-arm-kernel
> 
> On Mon, Jan 18, 2016 at 2:04 AM, Simon Horman
> <horms+renesas@verge.net.au> wrote:
> > Update the mailing list used for development of support for
> > Renesas SoCs and related drivers.
> >
> > Up until now the linux-sh mailing list has been used, however,
> > Renesas SoCs are now much wider than the SH architecture and there
> > is some desire from some for the linux-sh list to refocus on
> > discussion of the work on the SH architecture.
> >
> > Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> > Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
> > Cc: Geert Uytterhoeven <geert+renesas@glider.be>
> > Cc: Magnus Damm <magnus.damm@gmail.com>
> > Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>
> 
> > ---
> > * This patch applies on top of Linus's tree where currently the head commit
> >   is 984065055e6e ("Merge branch 'drm-next' of
> >   git://people.freedesktop.org/~airlied/linux")
> >
> >   This has been used as a base instead of v4.4 so that it is based on the
> >   following two commits which affect it:
> >   - 1a4ca6dd3dc8 ("MAINTAINERS: Add co-maintainer for Renesas Pin Controllers")
> >   - 3e46c3973cba ("MAINTAINERS: add Renesas usb2 phy driver")
> 
> I assume you'll send an update for the "ARM/RENESAS ARM64 ARCHITECTURE"
> section as soon as that has landed in mainline?

Yes, that is my plan.
