From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: Use time_before()
Date: Wed, 21 May 2014 16:43:03 -0400 (EDT)
Message-ID: <20140521.164303.1327740853923724994.davem@davemloft.net>
References: <1400520928.30820.23.camel@joe-AO725>
	<1400533144-8473-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	joe@perches.com
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400533144-8473-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Mon, 19 May 2014 22:59:04 +0200

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_before() instead of plain, error-prone math.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied, thanks.
