From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/42] drivers/net/wan: Adjust confusing if indentation
Date: Mon, 16 Aug 2010 20:57:09 -0700 (PDT)
Message-ID: <20100816.205709.71100683.davem@davemloft.net>
References: <Pine.LNX.4.64.1008052216400.31692@ask.diku.dk>
	<m37hk21tv2.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: julia@diku.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m37hk21tv2.fsf@intrepid.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 07 Aug 2010 14:37:37 +0200

> Julia Lawall <julia@diku.dk> writes:
>=20
>>  drivers/net/wan/c101.c      |    2 +-
>>  drivers/net/wan/n2.c        |    2 +-
>>  drivers/net/wan/pci200syn.c |    2 +-
>=20
> Fully Acked-by: Krzysztof Ha=A9=A9asa <khc@pm.waw.pl>

Please don't use non-standard commit tags like this "Fully Acked-by:"
thing, otherwise automated tools won't notice and pick them up
properly.

Thanks.
