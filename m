From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 06 Nov 2009 09:47:37 +0100
Message-ID: <4AF3E2A9.2020601@gmail.com>
References: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>	 <4AC1D0F5.4050709@gmail.com>	 <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com>	 <4AEACD88.8080108@gmail.com> <4AEB0059.1050400@gmail.com> <38b2ab8a0911060045hb6ebab8p43bf8aa838eabfd3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Francis Moreau <francis.moro@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36021 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472AbZKFIrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 03:47:35 -0500
In-Reply-To: <38b2ab8a0911060045hb6ebab8p43bf8aa838eabfd3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancis Moreau a =E9crit :
> On Fri, Oct 30, 2009 at 4:03 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>=20
> [...]
>=20
>> [PATCH take2] net: fix sk_forward_alloc corruption
>>
>=20
> With this patch applied 4 days ago, I haven't got any oops so far.

Thanks a lot for testing and report Francis, I believe David will push =
it for stable
(if not already done)


