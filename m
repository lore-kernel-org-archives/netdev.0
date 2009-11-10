From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/10] net: use rcu for network scheduler API
Date: Tue, 10 Nov 2009 19:20:57 +0100
Message-ID: <4AF9AF09.60102@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.339425269@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33111 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756686AbZKJSUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:20:54 -0500
In-Reply-To: <20091110175647.339425269@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Use RCU to walk list of network devices in qdisc dump.
> This could be optimized for large number of devices.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
