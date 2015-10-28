From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Wed, 28 Oct 2015 12:57:28 +0100
Message-ID: <5630B828.6070500@gmx.net>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net> <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net> <20150923162650.148fe95b@urahara> <bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com> <20150924151630.28129cdb@urahara> <5604E357.9000802@gmx.net> <56308253.2060608@gmx.net> <20151028082815.GO26876@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:64717 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755529AbbJ1L5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 07:57:45 -0400
In-Reply-To: <20151028082815.GO26876@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA384

> I did not take over maintenance responsibility (whatever that means
> to you precisely). I merely reviewed the patches, focussing on the=20
> technical aspects of both implementation and patch management.

Ah, I meant the maintenance of iproute2 as a whole. Though, obviosly I
must have misconceived that.

>> Those resentments were related to the patchsets complexity and
>> size.
>=20
> I didn't see any problem with that in the first place. It is indeed
> a big change, achieving something like that without a big patch set
> is unlikely.
>=20

=46ine, I was just repounding that since Steven Hemminger raised that.
My reasoning here is that I just don't want to kick off restarting
work whith objections still in the minds =96 since we are already at V7
now.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCQAGBQJWMLgnAAoJEOAWT1uK3zQ7dMkH/jHps8no3c23LRXGnVaX08Ap
Eha6XWU9pHrCHAM2AF6XI8aKERjS00ycuC12rFKoPZC2sjSXv4PTGFJq9w8AF71K
os5PPi1iZRFQ/0tti7pMkGTmUwRrtHmdfGNKvu79oRJfADaqaNtpZV+4UiS2bPCP
jy+89mA02XXgJpNkJgG/md6wNFHEsJBUGtcx3KSWqYXHHpV2FJoN1H8P28ESVAJA
H2o1De6g7XBbSpigiHX8X69CkzjZor5cYyWF6W5lUNXhGCQ4xqmGJycNKjM3Et/g
OPXvcaRKwv2R06pSYzkQ17tsnm9u8+R/v3nQvFDJGD0+zZJsc+c2by2KTQt6qm4=3D
=3DONCK
-----END PGP SIGNATURE-----
