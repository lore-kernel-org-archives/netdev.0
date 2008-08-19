From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 22:30:14 -0700 (PDT)
Message-ID: <20080818.223014.229866558.davem@davemloft.net>
References: <20080818.171124.192743795.davem@davemloft.net>
	<20080818.210701.80578862.davem@davemloft.net>
	<Pine.LNX.4.64.0808190806120.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57905
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752207AbYHSFaO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 01:30:14 -0400
In-Reply-To: <Pine.LNX.4.64.0808190806120.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 19 Aug 2008 08:27:37 +0300 (EEST)

> pkt_sched: remove bogus block (cleanup)
>=20
> ...Last block local var got just deleted.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks!
