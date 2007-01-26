From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.20-rc6: known unfixed regressions (part 2)
Date: Fri, 26 Jan 2007 20:04:23 +0100
Message-ID: <45BA50B7.1070205@googlemail.com>
References: <Pine.LNX.4.64.0701241847360.25027@woody.linux-foundation.org> <20070126181132.GN17836@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Uwe Bugla <uwe.bugla@gmx.de>, B.Zolnierkiewicz@elka.pw.edu.pl,
	linux-ide@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	Gerhard Dirschl <gd@spherenet.de>,
	Christoph Hellwig <hch@lst.de>, petero2@telia.com,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	David Miller <davem@davemloft.net>, sds@tycho.nsa.gov,
	jmorris@namei.org, netdev@vger.kernel.org,
	Livio Soares <livio@eecg.toronto.edu>,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org,
	Cijoml Cijomlovic Cijomlov <cijoml@volny.cz>,
	Nick Piggin <nickpiggin@yahoo.com.au>, ttb@tentacle.dhs.org,
	rml@novell.com, =?UTF-8?B?TWFsdGUgU2NocsO2ZGVy?= <MalteSch@gmx.de>,
	"Vladimir V. Saveliev" <vs@namesys.com>, reiserfs-dev@namesys.com,
	Sam
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:49988 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161188AbXAZTEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 14:04:40 -0500
Received: by ug-out-1314.google.com with SMTP id 44so792356uga
        for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 11:04:39 -0800 (PST)
In-Reply-To: <20070126181132.GN17836@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Adrian Bunk napisa=C5=82(a):
> This email lists some known regressions in 2.6.20-rc6 compared to 2.6=
=2E19
> that are not yet fixed in Linus' tree.
>=20
> If you find your name in the Cc header, you are either submitter of o=
ne
> of the bugs, maintainer of an affectected subsystem or driver, a patc=
h
> of you caused a breakage or I'm considering you in any other way poss=
ibly
> involved with one or more of these issues.
>=20
> Due to the huge amount of recipients, please trim the Cc when answeri=
ng.
>=20
>=20
> Subject    : SELinux compile error with CONFIG_XFRM=3Dn
> References : http://lkml.org/lkml/2007/1/25/233
> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Caused-By  : Venkat Yekkirala <vyekkirala@TrustedCS.com>
>              commit 334c85569b8adeaa820c0f2fab3c8f0a9dc8b92e
> Handled-By : Venkat Yekkirala <vyekkirala@TrustedCS.com>
>              David Miller <davem@davemloft.net>
> Status     : problem is being discussed
>=20

Venkat Yekkirala has sent me a patch that fixed this build problem.

Thanks!

Regards,
Michal

--=20
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/)
