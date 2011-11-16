From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5 3/9] net: split netdev features to separate header
Date: Wed, 16 Nov 2011 02:14:20 +0000
Message-ID: <1321409660.2744.38.camel@bwh-desktop>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
	 <e2c98cf47788fb0e2b2272b78486aeca30dde5db.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57658 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201Ab1KPCOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 21:14:24 -0500
In-Reply-To: <e2c98cf47788fb0e2b2272b78486aeca30dde5db.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 02:29 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Move features definitions to separate header so that linux/skbuff.h w=
on't
> need to include linux/netdevice.h after netdev_features_t is introduc=
ed.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
