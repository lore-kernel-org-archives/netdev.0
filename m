From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: kernel Error
Date: Sat, 02 Jun 2007 18:04:45 +0200
Message-ID: <4661951D.4010904@googlemail.com>
References: <2658.63.219.2.2.1180776292.squirrel@mail.websurfer.com.np>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: umesh@websurfer.com.np
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:51795 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149AbXFBQFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 12:05:01 -0400
Received: by ug-out-1314.google.com with SMTP id j3so429588ugf
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2007 09:04:59 -0700 (PDT)
In-Reply-To: <2658.63.219.2.2.1180776292.squirrel@mail.websurfer.com.np>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[netdev added to CC]

umesh@websurfer.com.np pisze:
> I got following error message when I try to upload file to remote ser=
ver.
> The log generated in remote server is as per below.
>=20
> KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1284)
> recvmsg bug: copied BC00D548 seq BC00DAFC
> KERNEL: assertion (tp->copied_seq =3D=3D tp->rcv_nxt || (flags & (MSG=
_PEEK |
> MSG_TRUNC))) failed at net/ipv4/tcp.c (1348)
> KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1284)
> recvmsg bug: copied BC00D548 seq BC00DAFC
> KERNEL: assertion (tp->copied_seq =3D=3D tp->rcv_nxt || (flags & (MSG=
_PEEK |
> MSG_TRUNC))) failed at net/ipv4/tcp.c (1348)
> KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1284)
>=20
> Umesh
>=20

Please read REPORTING-BUGS and send more details

Regards,
Michal

--=20
"Najbardziej brakowa=C5=82o mi twojego milczenia."
-- Andrzej Sapkowski "Co=C5=9B wi=C4=99cej"

