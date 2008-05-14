From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 09:06:16 -0700
Message-ID: <482B0DF8.9060001@redhat.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com> <20080514080942.GB4462@gerrit.erg.abdn.ac.uk> <482AF1DB.1060608@redhat.com> <20080514144518.GA30578@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ulrich Drepper <drepper@redhat.com>,
	R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180AbYENQLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 12:11:34 -0400
In-Reply-To: <20080514144518.GA30578@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Gerrit Renker wrote:
> ... but it would still be good to have.=20
> [...]

Thanks, but I think I got this already from previous mails.

The question is: is either DCCP or UDPlite important enough to be
returned in the default list when socktype and protocol are zero?

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKw342ijCOnn/RHQRAmnrAKCO0sevJbyZXNoFG12jSg1NjPC+5wCfUlyH
cLqvVRQ1gmTkkwl5JnqA9go=3D
=3DQRU/
-----END PGP SIGNATURE-----
