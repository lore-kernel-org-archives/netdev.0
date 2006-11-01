From: Libor =?utf-8?q?Klep=C3=A1=C4=8D?= <libor.klepac@bcom.cz>
Subject: Re: r8169 and region #2 not an MMIO resource
Date: Wed, 1 Nov 2006 23:36:19 +0100
Message-ID: <200611012336.22546.libor.klepac@bcom.cz>
References: <200611012221.46981.libor.klepac@bcom.cz> <20061101220036.GA3260@electric-eye.fr.zoreil.com> <20061101221337.GB3260@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart12778424.Eqctpp8EIv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.webx.cz ([82.208.12.1]:34994 "EHLO mail.webx.cz")
	by vger.kernel.org with ESMTP id S1752541AbWKAWsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 17:48:55 -0500
Received: from localhost (ns.webx.cz [127.0.0.1])
	by mail.webx.cz (Postfix) with ESMTP id 7AFDD41C1CC
	for <netdev@vger.kernel.org>; Wed,  1 Nov 2006 23:48:54 +0100 (CET)
Received: from mail.webx.cz ([127.0.0.1])
	by localhost (ns.webx.cz [127.0.0.1]) (amavisd-new, port 10042)
	with ESMTP id 6z8dDVv9p4EH for <netdev@vger.kernel.org>;
	Wed,  1 Nov 2006 23:48:54 +0100 (CET)
Received: from leviathan.mugn.local (76-82-244-84.zapcechy.adsl-llu.static.bluetone.cz [84.244.82.76])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.webx.cz (Postfix) with ESMTP id 2B7E241C222
	for <netdev@vger.kernel.org>; Wed,  1 Nov 2006 23:36:46 +0100 (CET)
To: netdev@vger.kernel.org
In-Reply-To: <20061101221337.GB3260@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart12778424.Eqctpp8EIv
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Dne st=C5=99eda 01 listopad 2006 23:13 Francois Romieu napsal(a):
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>
> > Please send lspci -vvx, I need the hexadecimal ID.
>
> Actually, no. This is a 8167, 2.6.19-rc4 includes the correct code for it.

ok, thanks, i'll try this version

libor

--nextPart12778424.Eqctpp8EIv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFSSFmhMrxGRe1HmERAp9pAKC0KM5u4bM3fzBauhXusTSA77ywlACeJdGv
MHvjox65g202zBw0GWfcWY4=
=QJT4
-----END PGP SIGNATURE-----

--nextPart12778424.Eqctpp8EIv--
