From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2013-06-11
Date: Wed, 12 Jun 2013 15:01:59 -0700 (PDT)
Message-ID: <20130612.150159.936180836505278347.davem@davemloft.net>
References: <20130611190546.GE3196@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756816Ab3FLWCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:02:03 -0400
In-Reply-To: <20130611190546.GE3196@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 11 Jun 2013 15:05:48 -0400

> This pull request is intended for the 3.11 stream...
>=20
> One big highlight is the cw1200 driver the ST-E CW1100 & CW1200
> WLAN chipsets.  This one has been lingering for a while, lacking
> some review comments.  Once started getting pulled into linux-next,
> it got a bit more attention and a number of improvements were made
> over the initial cut.  No doubt there will be more changes ahead,
> but I think it is looking alright at this point.
>=20
> Along with that, there is the usual flurry of updates to the mac80211
> core and the iwlwifi, mwifiex, ath9k, rt2x00, wil6210, and other
> drivers.  A few of the highlights are some rt2x00 refactoring/cleanup
> by Gabor Juhos, some rt2800 hardware support enhancements by Stanisla=
w
> Gruszka, some iwlwifi power management updates from Alexander Bondar,
> some enhanced bcma SPROM support from Rafa=A9=A9 Mi=A9=A9ecki, and a =
variety
> of other things here and there.

Pulled, thanks John.
