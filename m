From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] caif: Add CAIF HSI Link layer driver
Date: Wed, 01 Jun 2011 21:17:03 -0700 (PDT)
Message-ID: <20110601.211703.1666052113621925940.davem@davemloft.net>
References: <1306934958-5666-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Dmitry.Tarnyagin@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab1FBERI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 00:17:08 -0400
In-Reply-To: <1306934958-5666-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Wed,  1 Jun 2011 15:29:18 +0200

> From: Dmitry.Tarnyagin <Dmitry.Tarnyagin@stericsson.com>
>=20
> This patch introduces the CAIF HSI Protocol Driver for the
> CAIF Link Layer.
>=20
> This driver implements a platform driver to accommodate for a
> platform specific HSI devices. A general platform driver is not
> possible as there are no HSI side Kernel API defined.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied to net-next-2.6
