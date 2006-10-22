From: Norbert Preining <preining@logic.at>
Subject: Re: tg3 kernel bug in 2.6.18-mm3 and 2.6.19-rc2-mm2
Date: Sun, 22 Oct 2006 20:13:13 +0200
Message-ID: <20061022181313.GB21463@gamma.logic.tuwien.ac.at>
References: <20061021132239.GA29288@gamma.logic.tuwien.ac.at> <20061021.123814.106436476.davem@davemloft.net> <20061021233610.f190e0a8.akpm@osdl.org> <20061021234107.GA12918@gamma.logic.tuwien.ac.at> <1551EAE59135BE47B544934E30FC4FC093FC5D@NT-IRVA-0751.brcm.ad.broadcom.com> <20061022162251.GA11663@gamma.logic.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.logic.tuwien.ac.at ([128.130.175.20]:15072 "EHLO
	alpha.logic.tuwien.ac.at") by vger.kernel.org with ESMTP
	id S1750779AbWJVSNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 14:13:20 -0400
To: Michael Chan <mchan@broadcom.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061022162251.GA11663@gamma.logic.tuwien.ac.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all!

Ok, you will lough at me...

On Son, 22 Okt 2006, preining wrote:
> > > 2.6.19-rc2	works
> > > 2.6.19-rc2+patch does not work
> > >=20
> > It doesn't make any sense.  This patch is totally benign and
> > cannot cause the "No firmware running" and lockup that you
> > reported.  Can you please double-check?
>=20
> Ok, I cannot reproduce it anymore. No idea why it happened.

And again I can reporduce it. How, (again, please don't lough):

I booted into windows (sometimes one has too, contract from the EC with
macros in Excel tables ... grrr).

WinXP didn't mange to get an IP address from my cable modem.

Rebooting into linux, same problem as reported,=20

and, but no idea whether this is related: the modem just looses sync an=
d
need several resets until it find back into syncronization.

I will do some more experiments with Win-different linux kernel
switching.

Sorry for the chaos, no idea what has happened here!!!

Best wishes

Norbert

-----------------------------------------------------------------------=
--------
Dr. Norbert Preining <preining@logic.at>                    Universit=E0=
 di Siena
Debian Developer <preining@debian.org>                         Debian T=
eX Group
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 0=
9C5 B094
-----------------------------------------------------------------------=
--------
`We've got to find out what people want from fire, how
they relate to it, what sort of image it has for them.'
The crowd were tense. They were expecting something
wonderful from Ford.
`Stick it up your nose,' he said.
`Which is precisely the sort of thing we need to know,'
insisted the girl, `Do people want fire that can be fitted
nasally?'
                 --- Ford "debating" what to do with fire with a market=
ing
                 --- girl.
                 --- Douglas Adams, The Hitchhikers Guide to the Galaxy
