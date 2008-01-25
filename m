From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] [NET]: Remove PowerPC code from fec.c
Date: Fri, 25 Jan 2008 15:46:24 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801251544480.13060@anakin>
References: <4799F349.9090102@scram.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Garzik, Jeff" <jgarzik@pobox.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Scott Wood <scottwood@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	"Kernel, Linux" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>,
	uClinux list <uclinux-dev@uclinux.org>
To: Jochen Friedrich <jochen@scram.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758271AbYAYOqk@vger.kernel.org>
In-Reply-To: <4799F349.9090102@scram.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Jan 2008, Jochen Friedrich wrote:
> fec.c is only used on M68k Coldfire CPUs. Remove leftover
> PowerPC code from this driver.

As per MAINTAINERS, m68knommu is handled by:

UCLINUX (AND M68KNOMMU)
P:	Greg Ungerer
M:	gerg@uclinux.org
L:	uclinux-dev@uclinux.org  (subscribers-only)

I already forwarded a copy of your email to Greg.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
