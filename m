From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-08-28
Date: Mon, 01 Sep 2014 18:08:34 -0700 (PDT)
Message-ID: <20140901.180834.2149952137973916395.davem@davemloft.net>
References: <20140828181713.GL13758@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140828181713.GL13758@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 28 Aug 2014 14:17:14 -0400

> Please pull this batch of fixes intended for the 3.17 stream.
>=20
> For the Bluetooth/6LowPAN/802.15.4 bits, Johan says:
>=20
> 'It contains a connection reference counting fix for LE where a
> connection might stay up even though it should get disconnected.
>=20
> The other 802.15.4 6LoWPAN related patches were sent to the bluetooth
> tree by Alexander Aring and described as follows by him:
>=20
> "
> these patches contains patches for the bluetooth branch.
>=20
> This series includes memory leak fixes and an errno value fix.
> Also there are two patches for sending and receiving 1280 6LoWPAN
> packets, which makes the IEEE 802.15.4 6LoWPAN stack more RFC
> compliant.
> "'
>=20
> Along with that...
>=20
> Alexey Khoroshilov fixes a use-after-free bug on at76c50x-usb.
>=20
> Hauke Mehrtens adds a PCI ID to bcma.
>=20
> Himangi Saraogi fixes a silly "A || A" test in rtlwifi.
>=20
> Larry Finger adds a device ID to rtl8192cu.
>=20
> Maks Naumov fixes a strncmp argument in ath9k.
>=20
> =C1lvaro Fern=E1ndez Rojas adds a PCI ID to ssb.
>=20
> Please let me know if there are problems!

Pulled, thanks a lot John.
