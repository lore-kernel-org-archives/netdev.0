From: Andreas Schwab <schwab@suse.de>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Fri, 17 Nov 2006 12:30:58 +0100
Message-ID: <jemz6qs425.fsf@sykes.suse.de>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de>
	<20061114142959.GA17486@keitarou> <200611161507.33971.mb@bu3sch.de>
	<1163749589.5826.5.camel@localhost.localdomain>
	<1163750030.4047.1.camel@ux156>
	<1163750573.5826.7.camel@localhost.localdomain>
	<jeveles6lx.fsf@sykes.suse.de> <1163761482.4047.4.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org,
	Paul TBBle Hampson <Paul.Hampson@pobox.com>,
	linville@tuxdriver.com, Michael Buesch <mb@bu3sch.de>,
	bcm43xx-dev@lists.berlios.de, Martin Langer <martin-langer@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:32190 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1755693AbWKQLbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 06:31:07 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163761482.4047.4.camel@ux156> (Johannes Berg's message of "Fri,
	17 Nov 2006 12:04:42 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> writes:

> Try these:
>
> Support for bcmwl5.sys v4.80.53.0 added.
> ftp://downloads.netgear.com/files/wn511b_sw_3_28_3_8_setup.zip
> (bcmwl5.sys is renamed to wn511b.sys)

No supported files in there.

> Support for bcmwl5(64).sys v4.100.15.5 added.
> from the latest Linksys WPC300N driver at
> http://www.linksys.com/download/
> It's ucode revision 0x0173, patchlevel 0x0425, 2006-10-04.

Requires Javascript.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
