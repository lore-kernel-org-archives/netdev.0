From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: explicitly include core.h in addr.h
Date: Tue, 04 Feb 2014 20:33:25 -0800 (PST)
Message-ID: <20140204.203325.989285880722993205.davem@davemloft.net>
References: <1391525361-31839-1-git-send-email-andreas.bofjall@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	maloy@donjonn.com
To: andreas.bofjall@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbaBEEd0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:33:26 -0500
In-Reply-To: <1391525361-31839-1-git-send-email-andreas.bofjall@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: <andreas.bofjall@ericsson.com>
Date: Tue, 4 Feb 2014 15:49:21 +0100

> From: Andreas Bofj=E4ll <andreas.bofjall@ericsson.com>
>=20
> The inline functions in addr.h uses tipc_own_addr which is exported b=
y
> core.h, but addr.h never actually includes it. It works because it is
> explicitly included where this is used, but it looks a bit strange.
>=20
> Include core.h in addr.h explicitly to make the dependency clearer.
>=20
> Signed-off-by: Andreas Bofj=E4ll <andreas.bofjall@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

The net-next tree is not open at this time.  Please resubmit this
when the net-next tree opens back up.

Thank you.
