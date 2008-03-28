From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] [NET]: uninline skb_push, de-bloats a lot
Date: Thu, 27 Mar 2008 17:52:48 -0700 (PDT)
Message-ID: <20080327.175248.223135849.davem@davemloft.net>
References: <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753173AbYC1Aws convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:52:48 -0400
In-Reply-To: <1206621486-5408-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 27 Mar 2008 14:38:03 +0200

> Allyesconfig (v2.6.24-mm1):
>=20
> -21593  356 funcs, 2418 +, 24011 -, diff: -21593 --- skb_push
>=20
> Without many debug related CONFIGs (v2.6.25-rc2-mm1):
>=20
> -13890  341 funcs, 189 +, 14079 -, diff: -13890 --- skb_push
> skb_push                      |  +46
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
