From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xilinx: Fix compiler warning
Date: Sun, 22 Jun 2014 17:15:25 -0700 (PDT)
Message-ID: <20140622.171525.1231955995045407676.davem@davemloft.net>
References: <53A6BAC5.80206@cogentembedded.com>
	<1403436294-21301-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sergei.shtylyov@cogentembedded.com, michal.simek@xilinx.com,
	anirudh@xilinx.com, John.Linn@xilinx.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403436294-21301-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Sun, 22 Jun 2014 13:24:54 +0200

> The time comparsion functions require arguments of type unsigned long
> instead of (signed) long.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied to net-next, thanks.
