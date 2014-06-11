From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] dns_resolver: assure that dns_query() result is
 null-terminated
Date: Wed, 11 Jun 2014 00:12:16 -0700 (PDT)
Message-ID: <20140611.001216.1631681094950454220.davem@davemloft.net>
References: <1402167681-24676-1-git-send-email-manuel.schoelling@gmx.de>
	<1402178245-8076-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402178245-8076-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Sat,  7 Jun 2014 23:57:25 +0200

> dns_query() credulously assumes that keys are null-terminated and
> returns a copy of a memory block that is off by one.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied, thanks.
