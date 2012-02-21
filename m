From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/6] datagram: Factor out sk queue referencing
Date: Tue, 21 Feb 2012 18:39:19 +0100
Message-ID: <1329845959.18384.21.camel@edumazet-laptop>
References: <4F43D49E.3010401@parallels.com>
	 <4F43D4B9.8030005@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38057 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443Ab2BURjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:39:24 -0500
Received: by werb13 with SMTP id b13so3964254wer.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:39:23 -0800 (PST)
In-Reply-To: <4F43D4B9.8030005@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 21:30 +0400, Pavel Emelyanov a =C3=
=A9crit :
> This makes lines shorter and simplifies further patching.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>  net/core/datagram.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/core/datagram.c b/net/core/datagram.c

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
