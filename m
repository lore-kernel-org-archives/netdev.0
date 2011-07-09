From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 18/21] net: typhoon: use common rx_copybreak handling
Date: Sat, 09 Jul 2011 13:46:54 -0400
Message-ID: <1310233614.12566.1.camel@obelisk.thedillows.org>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
	 <86c335595654802d096c5c6c79f5d3fb71d4bd22.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrix.voodoobox.net ([75.127.97.206]:60426 "EHLO
	matrix.voodoobox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694Ab1GIRrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 13:47:40 -0400
In-Reply-To: <86c335595654802d096c5c6c79f5d3fb71d4bd22.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-07-09 at 19:17 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> v2: fix inverted test on skb refill/reuse
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  drivers/net/typhoon.c |   26 +++++++-------------------

Looks good,

Acked-by: David Dillow <dave@thedillows.org>

