From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: Use time_after() for time comparison
Date: Sun, 18 May 2014 21:25:27 -0400 (EDT)
Message-ID: <20140518.212527.1931788955169993316.davem@davemloft.net>
References: <1400448769-5945-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400448769-5945-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Sun, 18 May 2014 23:32:49 +0200

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_after() instead of raw math.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied.
