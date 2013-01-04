From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-01-04
Date: Fri, 04 Jan 2013 13:24:26 -0800 (PST)
Message-ID: <20130104.132426.2174792167438869648.davem@davemloft.net>
References: <20130104205343.GB21871@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682Ab3ADVY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 16:24:27 -0500
In-Reply-To: <20130104205343.GB21871@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 4 Jan 2013 15:53:43 -0500

> Arend "fixes" a copyright notice in brcmsmac -- seems harmless.
>=20
> Christian Lamparter adds a device ID to p54usb, and changes the
> interface combinations reported by carl9170 in order to get it
> working again.
>=20
> Geert Uytterhoeven gives us a pair of fixes for Kconfig warnings
> about bcma and ssb.
>=20
> Hante Meuleman fixes some IE parsing to get AP mode working with
> WPA2 security.
>=20
> Jesper Juhl fixes a urb leak in rtlwifi.
>=20
> Jussi Kivilinna fixes some mis-usage of usb_alloc_coherent in rtlwifi=
,
> avoiding a BUG on ARM.
>=20
> Larry Finger provides a handful of rtlwifi fixes to avoid some log
> SPAM due to not checking the return of pci_map_single.
>=20
> Niels Ole Salscheider changes a usleep_range in brcmsmac to use udela=
y
> instead, avoiding a "BUG: scheduling while atomic".
>=20
> Rafa=A9=A9 Mi=A9=A9ecki fixes an ID for a serial flash in the bcma co=
de.
>=20
> Sujith Manoharan provides a pair of ath9k fixes, one for a compilatio=
n
> break and one to correct some gain-related initvals.
>=20
> Tomasz Guszkowski adds a device ID to p54usb.
>=20
> Vladimir Kondratiev fixes a Kconfig problem which cause ath9k_htc
> not to build properly.
>=20
> Please let me know if there are problems!

Pulled, thanks John.
