From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: separate RX descriptor setup code into a new
 function
Date: Tue, 29 Oct 2013 17:21:02 -0400 (EDT)
Message-ID: <20131029.172102.1702458840834353036.davem@davemloft.net>
References: <1382967629-3794-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039Ab3J2VVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 17:21:03 -0400
In-Reply-To: <1382967629-3794-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Mon, 28 Oct 2013 14:40:29 +0100

> This cleans code a bit and will be useful when allocating buffers in
> other places (like RX path, to avoid skb_copy_from_linear_data_offset=
).
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied to net-next, thanks.
