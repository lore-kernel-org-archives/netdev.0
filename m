From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] net: Introduce unregister_netdevice_many()
Date: Tue, 27 Oct 2009 18:40:15 +0100
Message-ID: <4AE7307F.3070802@gmail.com>
References: <4AE72813.5080709@gmail.com> <200910271926.41734.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39081 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713AbZJ0Rkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:40:41 -0400
In-Reply-To: <200910271926.41734.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :

> Looks like EXPORT_SYMBOL(unregister_netdevice_many) is missing?
>=20

I added it in following patch, when really needed/used

