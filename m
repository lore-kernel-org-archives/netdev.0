From: David Miller <davem@davemloft.net>
Subject: Re: ethtool: allow ETHTOOL_GSSET_INFO for users
Date: Sun, 22 Jan 2012 23:41:38 -0500 (EST)
Message-ID: <20120122.234138.1679393625473917340.davem@davemloft.net>
References: <197ddc79ac33a67c56b42a226af3f30056bceb5c.1327227549.git.mirq-linux@rere.qmqm.pl>
	<1327281557.8004.137.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab2AWEmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 23:42:51 -0500
In-Reply-To: <1327281557.8004.137.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 Jan 2012 01:19:17 +0000

> On Sun, 2012-01-22 at 11:20 +0100, Micha=A9=A9 Miros=A9=A9aw wrote:
>> Allow ETHTOOL_GSSET_INFO ethtool ioctl() for unprivileged users.
>> ETHTOOL_GSTRINGS is already allowed, but is unusable without this on=
e.
>>=20
>> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
