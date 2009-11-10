From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/10] netdev: add netdev_continue_rcu
Date: Tue, 10 Nov 2009 19:19:22 +0100
Message-ID: <4AF9AEAA.1080608@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.200655064@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33101 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbZKJSTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:19:31 -0500
In-Reply-To: <20091110175647.200655064@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This adds an RCU macro for continuing search, useful for some
> network devices like vlan.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

