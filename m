From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Tue, 3 Nov 2015 07:54:44 +0100
Message-ID: <56385A34.7040602@gmx.net>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
 <20150923162650.148fe95b@urahara>
 <bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com>
 <20150924151630.28129cdb@urahara> <5604E357.9000802@gmx.net>
 <b114412a541d4273a9a7a1c0ae4777df@HQ1WP-EXMB11.corp.brocade.com>
 <20151102150617.30d2e478@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha384;
 protocol="application/pgp-signature";
 boundary="JnS9rX1jbNn0c48FExAIU6NAx7awEOhMt"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:63683 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541AbbKCGzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 01:55:05 -0500
In-Reply-To: <20151102150617.30d2e478@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JnS9rX1jbNn0c48FExAIU6NAx7awEOhMt
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> Your perception is incorrect.
> I am still maintaining iproute2. Phil is just providing lots of feedbac=
k
> and new patches.
No offense intendet! I know, Phil has already clarified things in the
other responses. Maybe you overlooked those accidentally.

> The size of the change makes it harder to digest, and I do think
> adding JSON support is a good idea. Just concerned about the long
> term maintainance overhead. Plus I want the other utilities to have
> JSON output as well. Therefore this change is going to take longer
> to adopt and hopefull we can figure out a good way to do this kind
> of output.

I see! Well, do you conceive a decentralized approach or a centralized
one for all the utilities?
Decentralizied would be as things are now =96 I mean what my patch series=

tries to amount to.

> Almost want to go to C++ or something.

Would that be viable or is that a wishful line of thougts?


--JnS9rX1jbNn0c48FExAIU6NAx7awEOhMt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCQAGBQJWOFo0AAoJEOAWT1uK3zQ7jHgH/j5VUtJjWJ6vKOX3HYC7FPOs
gtWVgXLRswSr/MnFVS5+g9waC4NAftxawW8ZeS098JwwBtfVJJtXh1eDh9imIqbR
FY1H38806eQVEnYCL0vT8xXx1XpW+3SLC1g427b5jnboifhK0pz/NEpgn9L6mPLN
RxCB0SqaLvn3ri3ezlPDP2LPjyVFrGzTZGqXlRx6zCsd0nGPYrbS9kdFQASu4Xpd
JvQURSLGFVC8w8YUkUb76crNArrE2VBew770j44igPw5UIEXqRXi9aeydf88qmzj
3e3j7iecGCuFK601mAogZtWqQHIgesoXTj0+vRVkYlciXOZhxKhousQRLMPo0do=
=vwsM
-----END PGP SIGNATURE-----

--JnS9rX1jbNn0c48FExAIU6NAx7awEOhMt--
