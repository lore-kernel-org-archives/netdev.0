From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5 7/9] ethtool: prepare for larger netdev_features_t
 type
Date: Wed, 16 Nov 2011 22:43:29 +0000
Message-ID: <1321483409.2709.31.camel@bwh-desktop>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
	 <77229786587ed90001dfee923c1d7794b758e3e1.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34429 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab1KPWng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:43:36 -0500
In-Reply-To: <77229786587ed90001dfee923c1d7794b758e3e1.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 02:29 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> v2:	changed loop in ethtool_set_features() per Ben's suggestion
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Run checkpatch and fix the spacing complaints.  After that, consider
this:

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
