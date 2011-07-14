From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] net: m68k/nfeth: Remove wrong usage of dev->flags
Date: Thu, 14 Jul 2011 14:38:25 -0700 (PDT)
Message-ID: <20110714.143825.1764065793604370659.davem@davemloft.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<4ce98e5d11f271278ef1ddf3e6186f31c7eef2aa.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, geert@linux-m68k.org,
	linux-m68k@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4ce98e5d11f271278ef1ddf3e6186f31c7eef2aa.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)

> Remove wrong setting of dev->flags. NETIF_F_NO_CSUM maps to IFF_DEBUG
> there, so looks like a mistake.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
