From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 2/5 RFC] TCPCT part1b: TCP_MSS_DEFAULT,
 TCP_MSS_DESIRED
Date: Mon, 09 Nov 2009 17:39:06 +0100
Message-ID: <4AF845AA.1020003@gmail.com>
References: <4AF83E2D.1050401@gmail.com> <4AF84248.1070103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53920 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbZKIQjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 11:39:04 -0500
In-Reply-To: <4AF84248.1070103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Define two symbols needed in both kernel and user space.
>=20
> Remove old (somewhat incorrect) variant that wasn't used in many case=
s.
> Default applies to both RMSS and SMSS.
>=20
> Replace numeric constants with defined symbols.
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/linux/tcp.h      |    6 ++++++
>  include/net/tcp.h        |    3 ---
>  net/ipv4/tcp_input.c     |    4 ++--
>  net/ipv4/tcp_ipv4.c      |    6 +++---
>  net/ipv4/tcp_minisocks.c |    2 +-
>  net/ipv6/tcp_ipv6.c      |    2 +-
>  6 files changed, 13 insertions(+), 10 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

