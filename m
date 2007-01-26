From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: 2.6.20-rc6: known unfixed regressions (part 2)
Date: Fri, 26 Jan 2007 13:08:58 -0600
Message-ID: <002f01c7417d$6f67cea0$cc0a010a@tcssec.com>
References: <45BA50B7.1070205@googlemail.com>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "'Michal Piotrowski'" <michal.k.k.piotrowski@gmail.com>,
	"Adrian Bunk" <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:4889 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161181AbXAZTKr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 14:10:47 -0500
In-Reply-To: <45BA50B7.1070205@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46YI- The patch can be viewed here:

http://marc.theaimsgroup.com/?l=3Dlinux-netdev&m=3D116983297300536&w=3D=
2

> -----Original Message-----
> From: Michal Piotrowski [mailto:michal.k.k.piotrowski@gmail.com]
> Sent: Friday, January 26, 2007 1:04 PM
> To: Adrian Bunk
> Cc: Linus Torvalds; Andrew Morton; Linux Kernel Mailing List;=20
> Uwe Bugla;
> B.Zolnierkiewicz@elka.pw.edu.pl; linux-ide@vger.kernel.org;
> alan@lxorguk.ukuu.org.uk; Gerhard Dirschl; Christoph Hellwig;
> petero2@telia.com; Michal Piotrowski; Venkat Yekkirala; David Miller;
> sds@tycho.nsa.gov; jmorris@namei.org; netdev@vger.kernel.org; Livio
> Soares; Paul Mackerras; linuxppc-dev@ozlabs.org; Cijoml Cijomlovic
> Cijomlov; Nick Piggin; ttb@tentacle.dhs.org; rml@novell.com; Malte
> Schr=C3=B6der; Vladimir V. Saveliev; reiserfs-dev@namesys.com; Sami F=
arin;
> David Chinner; xfs-masters@oss.sgi.com
> Subject: Re: 2.6.20-rc6: known unfixed regressions (part 2)
>=20
>=20
> Hi,
>=20
> Adrian Bunk napisa=C5=82(a):
> > This email lists some known regressions in 2.6.20-rc6=20
> compared to 2.6.19
> > that are not yet fixed in Linus' tree.
> >=20
> > If you find your name in the Cc header, you are either=20
> submitter of one
> > of the bugs, maintainer of an affectected subsystem or=20
> driver, a patch
> > of you caused a breakage or I'm considering you in any=20
> other way possibly
> > involved with one or more of these issues.
> >=20
> > Due to the huge amount of recipients, please trim the Cc=20
> when answering.
> >=20
> >=20
> > Subject    : SELinux compile error with CONFIG_XFRM=3Dn
> > References : http://lkml.org/lkml/2007/1/25/233
> > Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> > Caused-By  : Venkat Yekkirala <vyekkirala@TrustedCS.com>
> >              commit 334c85569b8adeaa820c0f2fab3c8f0a9dc8b92e
> > Handled-By : Venkat Yekkirala <vyekkirala@TrustedCS.com>
> >              David Miller <davem@davemloft.net>
> > Status     : problem is being discussed
> >=20
>=20
> Venkat Yekkirala has sent me a patch that fixed this build problem.
>=20
> Thanks!
>=20
> Regards,
> Michal
>=20
> --=20
> Michal K. K. Piotrowski
> LTG - Linux Testers Group
> (http://www.stardust.webpages.pl/ltg/)
>=20

