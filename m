From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: remove unneeded dirty_rx index
Date: Wed, 16 Jan 2013 18:02:41 -0500 (EST)
Message-ID: <20130116.180241.577406705639005581.davem@davemloft.net>
References: <20130115225316.GA924@electric-eye.fr.zoreil.com>
	<1358319684-32364-1-git-send-email-timo.teras@iki.fi>
	<20130116221640.GB32073@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756668Ab3APXCm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 18:02:42 -0500
In-Reply-To: <20130116221640.GB32073@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 16 Jan 2013 23:16:40 +0100

> Timo Ter=E4s <timo.teras@iki.fi> :
>> After commit 6f0333b ("r8169: use 50% less ram for RX ring") the rx
>> ring buffers are always copied making dirty_rx useless.
>>=20
>> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied to net-next.
