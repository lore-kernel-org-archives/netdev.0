From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH RESEND net-next] ethtool: bring back missing comma in
 netdev features strings
Date: Thu, 12 May 2011 18:45:12 +0200
Message-ID: <BANLkTikW=vURi7sAQ9ZJdgy=JDv+JacTQQ@mail.gmail.com>
References: <20110512164204.EC8391220061@host64.kissl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maheshb@google.com
To: franco@lastsummer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:62865 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757905Ab1ELQpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 12:45:33 -0400
Received: by qyg14 with SMTP id 14so1003020qyg.19
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 09:45:32 -0700 (PDT)
In-Reply-To: <20110512164204.EC8391220061@host64.kissl.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/12  <franco@lastsummer.de>:
> The issue was introduced in commit eed2a12f1ed9aabf.
>
> Signed-off-by: Franco Fichtner <franco@lastsummer.de>
> ---
> =C2=A0net/core/ethtool.c | =C2=A0 =C2=A02 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index b6f4058..b8c2b10 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -361,7 +361,7 @@ static const char
> netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_NTUPLE */ =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0"rx-ntuple-filter",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_RXHASH */ =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0"rx-hashing",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_RXCSUM */ =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0"rx-checksum",
> - =C2=A0 =C2=A0 =C2=A0 /* NETIF_F_NOCACHE_COPY */ =C2=A0 =C2=A0"tx-no=
cache-copy"
> + =C2=A0 =C2=A0 =C2=A0 /* NETIF_F_NOCACHE_COPY */ =C2=A0 =C2=A0"tx-no=
cache-copy",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_LOOPBACK */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0"loopback",
> =C2=A0};

Acked-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
