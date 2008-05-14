From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 10:57:24 -0700
Message-ID: <482B2804.7040604@redhat.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk>	 <20080513162325.GF15306@ghostprotocols.net>	 <20080513170325.GB11499@gerrit.erg.abdn.ac.uk>	 <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com>	 <20080514080942.GB4462@gerrit.erg.abdn.ac.uk> <482AF1DB.1060608@redhat.com>	 <20080514144518.GA30578@gerrit.erg.abdn.ac.uk>	 <482B0DF8.9060001@redhat.com> <1210786780.31221.8.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761315AbYENSDu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 14:03:50 -0400
In-Reply-To: <1210786780.31221.8.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Sridhar Samudrala wrote:
>>   SOCK_STREAM, IPPROTO_SCTP
>>   SOCK_SEQPACKET, IPPROTO_SCTP

This is also in.  Give it a try once the first glibc for F10 rawhide is
built.  Should happen before Monday next week.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKygE2ijCOnn/RHQRAmm8AKCroe3jOmDpovf7M7oUhfInIZv6FQCgvuLB
M3XI59EFGTdYxCwNGvDRTSA=3D
=3Dx83D
-----END PGP SIGNATURE-----
