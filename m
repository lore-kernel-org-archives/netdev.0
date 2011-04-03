From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next-2.6 2/6] sfc: Implement generic features
	interface
Date: Sun, 3 Apr 2011 22:13:22 +0200
Message-ID: <20110403201322.GA13122@rere.qmqm.pl>
References: <1301859889.2935.23.camel@localhost> <1301860281.2935.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39913 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114Ab1DCUNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Apr 2011 16:13:24 -0400
Content-Disposition: inline
In-Reply-To: <1301860281.2935.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 03, 2011 at 08:51:21PM +0100, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/efx.c        |   17 ++++++++-
>  drivers/net/sfc/ethtool.c    |   78 --------------------------------=
----------
>  drivers/net/sfc/net_driver.h |    2 -
>  drivers/net/sfc/rx.c         |    2 +-
>  4 files changed, 16 insertions(+), 83 deletions(-)
>=20
[cut patch]

Looks ok to me.

BTW, I noticed that TSO6 is not enabled in vlan_features. Is this inten=
tional?

Best Regards,
Micha=B3 Miros=B3aw
