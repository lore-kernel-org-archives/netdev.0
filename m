From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] xfrm6_tunnel: RCU conversion
Date: Sat, 24 Oct 2009 15:34:31 +0200
Message-ID: <4AE30267.3080905@gmail.com>
References: <4AE28047.1020904@gmail.com> <20091024.060920.258223911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48834 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360AbZJXNef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:34:35 -0400
In-Reply-To: <20091024.060920.258223911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> Nice work Eric, I applied all of your RCU conversions to
> net-next-2.6, thanks!
>=20
> Applying: ipv6 sit: RCU conversion phase I
> Applying: ipv6 sit: RCU conversion phase II
> Applying: xfrm6_tunnel: RCU conversion
> Applying: ipip: convert hash tables locking to RCU
> Applying: ip6tnl: convert hash tables locking to RCU
> Applying: gre: convert hash tables locking to RCU

Thanks a lot !


