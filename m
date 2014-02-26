From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv6: log src and dst along with "udp
 checksum is 0"
Date: Wed, 26 Feb 2014 15:47:12 -0500 (EST)
Message-ID: <20140226.154712.105201437529775778.davem@davemloft.net>
References: <1393359062-16844-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, joe@perches.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaBZUrO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:47:14 -0500
In-Reply-To: <1393359062-16844-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Tue, 25 Feb 2014 21:11:02 +0100

> These info messages are rather pointless without any means to identif=
y
> the source of the bogus packets.  Logging the src and dst addresses a=
nd
> ports may help a bit.
>=20
> Cc: Joe Perches <joe@perches.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
> v2: log port numbers too.  Suggested by Joe Perches

Applied.
