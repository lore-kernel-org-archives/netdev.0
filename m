From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] mISDN: Use time_before()
Date: Thu, 22 May 2014 15:50:45 -0400 (EDT)
Message-ID: <20140522.155045.105185041569272199.davem@davemloft.net>
References: <537CFE29.7050100@cogentembedded.com>
	<1400702928-29110-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400702928-29110-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Wed, 21 May 2014 22:08:47 +0200

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_before() instead of plain, error-prone math.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied.
