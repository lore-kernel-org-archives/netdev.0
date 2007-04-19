From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Thu, 19 Apr 2007 14:12:19 +0200
Message-ID: <46275CA3.1070503@trash.net>
References: <461D26CB.3010508@trash.net>	 <1176400428.24446.40.camel@nt.wq.cz>	<4623029A.2090906@trash.net>	 <20070416.171016.43503207.davem@davemloft.net> <4624C46D.1030609@trash.net>	 <1176900487.8348.36.camel@nt.wq.cz> <462625E4.8030802@trash.net> <1176982238.5032.22.camel@nt.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: =?ISO-8859-15?Q?Milan_Koci=E1n?= <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50935 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993245AbXDSMMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 08:12:38 -0400
In-Reply-To: <1176982238.5032.22.camel@nt.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milan Koci=E1n wrote:
> ok, here is new version. Sign is in patch. Is it correct?
>=20
> --- a/net/ipv4/fib_hash.c	2007-04-18 12:50:11.000000000 +0200
> +++ b/net/ipv4/fib_hash.c	2007-04-19 10:21:04.267136960 +0200
> [...]
> Signed-off-by: Milan Kocian <milon@wq.cz>


Looks good, thanks.

Acked-by: Patrick McHardy <kaber@trash.net>

