From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/25] mISDN: Convert pci_table entries to PCI_VDEVICE
 (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 19:07:04 -0700 (PDT)
Message-ID: <20100715.190704.246538713.davem@davemloft.net>
References: <201007152104.08458.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org, isdn@linux-pingi.de,
	akpm@linux-foundation.org, u.kleine-koenig@pengutronix.de,
	tj@kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: PeterHuewe@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007152104.08458.PeterHuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Peter H=FCwe <PeterHuewe@gmx.de>
Date: Thu, 15 Jul 2010 21:04:07 +0200

> From: Peter Huewe <peterhuewe@gmx.de>
>=20
> This patch converts pci_table entries, where .subvendor=3DPCI_ANY_ID =
and
> .subdevice=3DPCI_ANY_ID, .class=3D0 and .class_mask=3D0, to use the
> PCI_VDEVICE macro, and thus improves readability.
>=20
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Applied.
