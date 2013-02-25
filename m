From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][FIX] bgmac: fix indexing of 2nd level loops
Date: Mon, 25 Feb 2013 15:47:57 -0500 (EST)
Message-ID: <20130225.154757.915289505996222817.davem@davemloft.net>
References: <1361816546-10171-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tvb@able.be
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab3BYUr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:47:59 -0500
In-Reply-To: <1361816546-10171-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Mon, 25 Feb 2013 19:22:26 +0100

> We were using the same variable for iterating two nested loops.
>=20
> Reported-by: Tijs Van Buggenhout <tvb@able.be>
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied, thanks.
