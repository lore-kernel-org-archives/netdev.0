From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [NET]: uninline dst_release
Date: Thu, 27 Mar 2008 17:53:38 -0700 (PDT)
Message-ID: <20080327.175338.90156948.davem@davemloft.net>
References: <1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-5-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50247
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753623AbYC1Axi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:53:38 -0400
In-Reply-To: <1206621486-5408-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 27 Mar 2008 14:38:04 +0200

> Codiff stats (allyesconfig, v2.6.24-mm1):
> -16420  187 funcs, 103 +, 16523 -, diff: -16420 --- dst_release
>=20
> Without number of debug related CONFIGs (v2.6.25-rc2-mm1):
> -7257  186 funcs, 70 +, 7327 -, diff: -7257 --- dst_release
> dst_release                   |  +40
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
