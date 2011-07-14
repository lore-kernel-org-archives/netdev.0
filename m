From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] net: remove SK_ROUTE_CAPS from meta ematch
Date: Thu, 14 Jul 2011 14:46:07 -0700 (PDT)
Message-ID: <20110714.144607.627952274990382223.davem@davemloft.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab1GNVrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 17:47:15 -0400
In-Reply-To: <b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 02:10:30 +0200 (CEST)

> Remove it, as it indirectly exposes netdev features. It's not used in
> iproute2 (2.6.38) - is anything else using its interface?
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
