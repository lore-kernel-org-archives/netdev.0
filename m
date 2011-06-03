From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH] net: remove legacy ethtool ops
Date: Fri, 03 Jun 2011 19:34:32 +0100
Message-ID: <1307126072.2789.55.camel@bwh-desktop>
References: <20110507114802.A0C841389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	e1000-devel@lists.sourceforge.net
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9883 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab1FCSef convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 14:34:35 -0400
In-Reply-To: <20110507114802.A0C841389B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-05-07 at 13:48 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> As all drivers are converted, we may now remove discrete offload sett=
ing
> callback handling.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>=20
> Note: This needs to wait for Intel guys to finish conversion of their
> LAN drivers.
[...]

It's a bit disappointing that this didn't make it into 3.0.

Jeff, has there been any progress on your drivers?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

