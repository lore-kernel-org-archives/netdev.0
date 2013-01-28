From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9601: support dm9620 variant
Date: Mon, 28 Jan 2013 00:18:47 -0500 (EST)
Message-ID: <20130128.001847.110491728527295486.davem@davemloft.net>
References: <1359326062-5042-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, slawek@wernikowski.net
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab3A1FSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 00:18:50 -0500
In-Reply-To: <1359326062-5042-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter Korsgaard <jacmet@sunsite.dk>
Date: Sun, 27 Jan 2013 23:34:22 +0100

> dm9620 is a newer variant of dm9601 with more features (usb 2.0, chec=
ksum
> offload, ..), but it can also be put in a dm9601 compatible mode, all=
owing
> us to reuse the existing driver.
>=20
> This does mean that the extended features like checksum offload canno=
t be
> used, but that's hardly critical on a 100mbps interface.
>=20
> Thanks to S=A9=A9awek Wernikowski <slawek@wernikowski.net> for provid=
ing me
> with a dm9620 based device to test.
>=20
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied, thanks Peter.
