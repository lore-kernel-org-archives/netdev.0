From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit
Date: Fri, 25 Nov 2011 17:39:58 +0100
Message-ID: <1322239198.5793.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
	 <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59744 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab1KYQkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 11:40:01 -0500
Received: by vbbfc26 with SMTP id fc26so2322408vbb.19
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 08:40:00 -0800 (PST)
In-Reply-To: <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 novembre 2011 =C3=A0 17:36 +0100, Eric Dumazet a =C3=A9c=
rit :

> Could you send a sample pcap of such problem, but please include full
> tcp sesssion, from the first SYN packet, up to packets following
> restransmits.
>=20
> A diff of "netstat -s" taken before your session and after your sessi=
on
> on receiver would help too, if receiver is not a loaded machine of
> course.
>=20
> Also, what version of linux kernel are you using in receiver ?
>=20
>=20

Oh well, I meant sender , not receiver !
