From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Wed, 06 Jan 2010 07:03:58 +0100
Message-ID: <4B4427CE.1040203@gmail.com>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34834 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab0AFGEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 01:04:02 -0500
In-Reply-To: <20100105155047.13309.79610.stgit@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 16:50, Jesper Dangaard Brouer a =C3=A9crit :
> This is to be used together with switch technologies, like RFC3069,
> that where the individual ports are not allowed to communicate with
> each other, but they are allowed to talk to the upstream router.  As
> described in RFC 3069, it is possible to allow these hosts to
> communicate through the upstream router by proxy_arp'ing.
>=20

Reading RFC 3069, I dont understand why it needs support on hosts thems=
elves.


> This patch basically allow proxy arp replies back to the same
> interface (from which the ARP request/solicitation was received).

Could you give me an example of how it is used ?
Last time I played with proxy arp was 6 years ago :)

Thanks
