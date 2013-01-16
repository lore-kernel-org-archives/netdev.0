From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: remove unneeded dirty_rx index
Date: Wed, 16 Jan 2013 23:16:40 +0100
Message-ID: <20130116221640.GB32073@electric-eye.fr.zoreil.com>
References: <20130115225316.GA924@electric-eye.fr.zoreil.com> <1358319684-32364-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45241 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757681Ab3APWp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 17:45:28 -0500
Content-Disposition: inline
In-Reply-To: <1358319684-32364-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=C3=A4s <timo.teras@iki.fi> :
> After commit 6f0333b ("r8169: use 50% less ram for RX ring") the rx
> ring buffers are always copied making dirty_rx useless.
>=20
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Even if it is obviously not -net material, please specify the branch yo=
u
aim at (eg [PATCH net-next] or [PATCH net]).

--=20
Ueimor
