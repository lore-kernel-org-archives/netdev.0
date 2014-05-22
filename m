From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: Use time_after() for time comparison
Date: Thu, 22 May 2014 16:58:44 -0400 (EDT)
Message-ID: <20140522.165844.694155605608410652.davem@davemloft.net>
References: <1400790090-13404-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400790090-13404-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Thu, 22 May 2014 22:21:30 +0200

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_after() instead of plain, error-prone math.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

I'll let Jeff pick this up in his tree.
