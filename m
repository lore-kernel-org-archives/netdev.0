From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/14] ll_temac: delete unneeded test before of_node_put
Date: Fri, 08 Aug 2014 10:28:58 -0700 (PDT)
Message-ID: <20140808.102858.2296909606267579093.davem@davemloft.net>
References: <1407492475-26283-12-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michal.simek@xilinx.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, u.kleine-koenig@pengutronix.de
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407492475-26283-12-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Fri,  8 Aug 2014 12:07:53 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
>=20
> Of_node_put supports NULL as its argument, so the initial test is not
> necessary.
>=20
> Suggested by Uwe Kleine-K=F6nig.
>=20
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
