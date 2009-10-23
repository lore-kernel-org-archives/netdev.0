From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Modify bonding hash transmit policies to use the packet's
 source MAC address
Date: Fri, 23 Oct 2009 18:02:55 +0200
Message-ID: <4AE1D3AF.9050207@gmail.com>
References: <4AE1A37F.8010203@gmail.com> <20091023140845.GA24564@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38592 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbZJWQDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:03:09 -0400
In-Reply-To: <20091023140845.GA24564@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jasper Spaans a =E9crit :
> Modify bonding hash transmit policies to use the psource MAC address =
of
> the packet instead of the MAC address configured for the bonding devi=
ce.
>=20
> The old sitation conflicts with the documentation.
>=20
> Signed-off-by: Jasper Spaans <spaans@fox-it.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
