From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] [NET]: uninline skb_trim, de-bloats
Date: Thu, 27 Mar 2008 17:54:08 -0700 (PDT)
Message-ID: <20080327.175408.69286698.davem@davemloft.net>
References: <1206621486-5408-5-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-6-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753503AbYC1AyJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:54:09 -0400
In-Reply-To: <1206621486-5408-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 27 Mar 2008 14:38:05 +0200

> Allyesconfig (v2.6.24-mm1):
> -10976  209 funcs, 123 +, 11099 -, diff: -10976 --- skb_trim
>=20
> Without number of debug related CONFIGs (v2.6.25-rc2-mm1):
> -7360  192 funcs, 131 +, 7491 -, diff: -7360 --- skb_trim
> skb_trim                      |  +42
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
