From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Tue, 10 Nov 2009 04:43:33 +0100
Message-ID: <4AF8E165.6000801@gmail.com>
References: <4AF8C4E9.3030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57657 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbZKJDnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 22:43:31 -0500
In-Reply-To: <4AF8C4E9.3030907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> check the return value of ndo_select_queue()
>=20
> Check the return value of ndo_select_queue(). If the value isn't smal=
ler
> than the real_num_tx_queues, print a warning message, and reset it to=
 zero.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

