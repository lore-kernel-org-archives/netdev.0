From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] bgmac: allow bigger et_swtype nvram variable
Date: Mon, 16 Sep 2013 21:31:30 -0400 (EDT)
Message-ID: <20130916.213130.349125823544006415.davem@davemloft.net>
References: <1379276748-13687-1-git-send-email-zajec5@gmail.com>
	<1379278148-6966-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925Ab3IQBbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:31:31 -0400
In-Reply-To: <1379278148-6966-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Sun, 15 Sep 2013 22:49:08 +0200

> From: Hauke Mehrtens <hauke@hauke-m.de>
>=20
> Without this patch it is impossible to read et_swtype, because the 1
> byte space is needed for the terminating null byte. The max expected
> value is 0xF, so now it should be possible to read decimal form ("15"=
)
> and hex form ("0xF").
>=20
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.
