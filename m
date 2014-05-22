From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] micrel: Use time_before_eq()
Date: Thu, 22 May 2014 15:50:56 -0400 (EDT)
Message-ID: <20140522.155056.1319013021780564009.davem@davemloft.net>
References: <1400781165-26498-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jg1.han@samsung.com, dingtianhong@huawei.com,
	ebiederm@xmission.com, Julia.Lawall@lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400781165-26498-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Thu, 22 May 2014 19:52:45 +0200

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_before_eq() instead of plain, error-prone math.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied.
