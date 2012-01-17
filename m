From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix NULL-deref in WARN() in skb_gso_segment()
Date: Tue, 17 Jan 2012 15:51:34 -0500 (EST)
Message-ID: <20120117.155134.1264944705734563725.davem@davemloft.net>
References: <a9312f6addc77e2af43ef4e1cceb91676944ae3d.1326829994.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, joe@perches.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab2AQUvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:51:40 -0500
In-Reply-To: <a9312f6addc77e2af43ef4e1cceb91676944ae3d.1326829994.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 17 Jan 2012 21:00:40 +0100 (CET)

> Bug was introduced in commit c8f44affb7244f2ac3e703cab13d55ede27621bb=
=2E
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
