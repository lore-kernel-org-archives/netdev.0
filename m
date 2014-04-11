From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-04-10
Date: Fri, 11 Apr 2014 16:35:18 -0400 (EDT)
Message-ID: <20140411.163518.681796977501065636.davem@davemloft.net>
References: <20140410174547.GC13595@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754239AbaDKUfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 16:35:19 -0400
In-Reply-To: <20140410174547.GC13595@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 10 Apr 2014 13:45:47 -0400

> Please pull this batch of fixes intended for the 3.15 stream!
>=20
> Chun-Yeow Yeoh gives us an ath9k_htc fix so that mac80211 can report
> last_tx_rate correctly for those devices..
>=20
> Fariya Fatima has a number of small fixes for things identified by
> the static analysis folks in the new rsi driver.
>=20
> Felix Fietkau brings an ath9k fix to better support some older chips,
> and a fix for a scheduling while atomic bug introduced by an earlier
> patch.
>=20
> Janusz Dziedzic produced an ath9k fix to only enable DFS when a
> related build option is selected.
>=20
> Paul Bolle removes some dead code in rtlwifi.
>=20
> Rafa=A9=A9 Mi=A9=A9ecki fixes some b43 code that was accessing some r=
egisters
> with operations for the wrong register width.
>=20
> Please let me know if there are problems!

Pulled, thanks a lot John.
