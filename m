From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 1/4] caif-hsi: Remove wake line modification
 when flushing FIFO
Date: Tue, 06 Dec 2011 17:22:12 -0500 (EST)
Message-ID: <20111206.172212.194823153605590602.davem@davemloft.net>
References: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, christian.auby@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab1LFWWS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:22:18 -0500
In-Reply-To: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue,  6 Dec 2011 23:15:41 +0100

> From: Christian Auby <christian.auby@stericsson.com>
>=20
> Raising wake before flushing FIFO and lowering it after caused a
> spike on AC wake that were sometimes detected and acted upon by the
> modem. Fixed this by remove wake line modification when flushing FIFO=
=2E
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
