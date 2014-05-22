From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xilinx: Use time_before_eq()
Date: Thu, 22 May 2014 15:51:02 -0400 (EDT)
Message-ID: <20140522.155102.429779731290445105.davem@davemloft.net>
References: <1400785828-1551-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michal.simek@xilinx.com, anirudh@xilinx.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400785828-1551-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Thu, 22 May 2014 21:10:28 +0200

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_before_eq() instead of plain, error-prone math.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied.
