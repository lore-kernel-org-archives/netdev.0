From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] mISDN: Use mod_timer()
Date: Thu, 22 May 2014 15:50:51 -0400 (EDT)
Message-ID: <20140522.155051.371532707765196359.davem@davemloft.net>
References: <537CFE29.7050100@cogentembedded.com>
	<1400702928-29110-1-git-send-email-manuel.schoelling@gmx.de>
	<1400702928-29110-2-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400702928-29110-2-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Wed, 21 May 2014 22:08:48 +0200

> The code for resetting the timer can be simplified if mod_timer() is =
used
> instead of del_timer() followed by add_timer().
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied.
