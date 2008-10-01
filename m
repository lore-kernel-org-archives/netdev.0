From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] key: Free dumping state on socket close
Date: Wed, 01 Oct 2008 05:34:41 -0700 (PDT)
Message-ID: <20081001.053441.120231459.davem@davemloft.net>
References: <48E35713.6030200@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38424
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbYJAMex convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 08:34:53 -0400
In-Reply-To: <48E35713.6030200@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 01 Oct 2008 13:55:15 +0300

> Fix a xfrm_{state,policy}_walk leak if pfkey socket is closed while
> dumping is on-going.
>=20
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> ---
> Should go to -stable too.

Applied and queued for -stable, thanks!
