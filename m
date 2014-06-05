From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dns_resolver: Do not accept domain names longer than
 255 chars
Date: Thu, 05 Jun 2014 00:06:30 -0700 (PDT)
Message-ID: <20140605.000630.1200115376924354358.davem@davemloft.net>
References: <1401554673-16311-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401554673-16311-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Sat, 31 May 2014 18:44:33 +0200

> According to RFC1035 "[...] the total length of a domain name (i.e.,
> label octets and label length octets) is restricted to 255 octets or
> less."
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied to net-next, thanks.
