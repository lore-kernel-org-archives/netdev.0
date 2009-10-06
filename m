From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: arp_notify address list bug
Date: Tue, 06 Oct 2009 17:43:52 +0200
Message-ID: <4ACB65B8.2050106@gmail.com>
References: <20091005191505.75c929a6@nehalam>	<4ACAB5BC.1020307@gmail.com>	<20091005.213103.237708475.davem@davemloft.net>	<4ACAD393.5080909@gmail.com> <20091006082913.54883824@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47290 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758025AbZJFPod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 11:44:33 -0400
In-Reply-To: <20091006082913.54883824@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
>=20
> Okay, but I can't see that sending out one per address is going to be=
 a big
> storm. Can't imagine user with 100's of addresses on same interface, =
but I guess
> it is possible.
>=20

I saw some setups with hundred of ip addresses.

But they probably dont change MAC addresses very often :)

Who knows...
