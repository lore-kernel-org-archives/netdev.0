From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 06/10] s390: use RCU to walk list of network devices
Date: Tue, 10 Nov 2009 19:40:42 +0100
Message-ID: <4AF9B3AA.6070104@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.547660685@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org, linux390@de.ibm.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50613 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757312AbZKJSkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:40:40 -0500
In-Reply-To: <20091110175647.547660685@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This is similar to other cases where for_each_netdev_rcu
> can be used when gathering information.
>=20
> By inspection, don't have platform or cross-build environment
> to validate.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

