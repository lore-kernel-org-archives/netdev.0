From: Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>
Subject: Re: [Bugme-new] [Bug 14002] New: WARNING: at
 net/ipv4/af_inet.c:154 inet_sock_destruct+0x164/0x1c0()
Date: Thu, 20 Aug 2009 10:49:37 +0200
Message-ID: <20090820084936.GO28851@charite.de>
References: <bug-14002-10286@http.bugzilla.kernel.org/>
 <20090819142145.b3c9fdc1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ausfall.charite.de ([193.175.70.131]:34259 "EHLO
	mail-ausfall.charite.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbZHTIti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 04:49:38 -0400
Content-Disposition: inline
In-Reply-To: <20090819142145.b3c9fdc1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Andrew Morton <akpm@linux-foundation.org>:

> > Aug 17 17:03:01 vpn-gw-int kernel: [507970.165477] 172.28.33.133IN=3D=
tun0
> > OUT=3Deth0 SRC=3D172.28.33.133 DST=3D141.80.40.193 LEN=3D67 TOS=3D0=
x00 PREC=3D0x00 TTL=3D127
> > ID=3D23900 PROTO=3DUDP
> > SPT=3D1026 DPT=3D53 LEN=3D47
>=20
> Is it reproducible?  Still happening in current mainline?

I updated to 2.6.31-rc6 and haven't (yet) seen it.

--=20
Ralf Hildebrandt
  Gesch=C3=A4ftsbereich IT | Abteilung Netzwerk
  Charit=C3=A9 - Universit=C3=A4tsmedizin Berlin
  Campus Benjamin Franklin
  Hindenburgdamm 30 | D-12203 Berlin
  Tel. +49 30 450 570 155 | Fax: +49 30 450 570 962
  ralf.hildebrandt@charite.de | http://www.charite.de
	   =20
