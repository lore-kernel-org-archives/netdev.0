From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH 0/9] Cleanup and extension of netdev features
Date: Tue, 21 Jun 2011 22:52:03 +0100
Message-ID: <1308693123.2743.71.camel@bwh-desktop>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	 <4E011080.7000008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24652 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873Ab1FUVwH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 17:52:07 -0400
In-Reply-To: <4E011080.7000008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-21 at 14:43 -0700, Ben Greear wrote:
> On 06/20/2011 12:14 PM, Micha=C5=82 Miros=C5=82aw wrote:
> > This is a preview of the cleanups pending after getting rid of old
> > ethtool ops from remaining drivers.
>=20
> Even when skipping patch 1 (seems this was just merged earlier today)=
,
> these patches do not all apply to net-next.
>=20
> They are also full of white-space warnings.
>=20
> Please re-post them when you sync against upstream
> and I'll try to do some testing.
>=20
> Also, do you have a cooresponding patch against ethtool
> to make it able to handle the new 64-bit flags?

It doesn't handle named features at all yet, though Micha=C5=82 has
previously prepared patches to do so.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

