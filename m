From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] caif: Add wakeline status tracking
Date: Thu, 02 Feb 2012 14:30:03 -0500 (EST)
Message-ID: <20120202.143003.1765087987294454113.davem@davemloft.net>
References: <1328181565-13781-1-git-send-email-sjur.brandeland@stericsson.com>
	<1328181565-13781-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757330Ab2BBTaI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:30:08 -0500
In-Reply-To: <1328181565-13781-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Thu,  2 Feb 2012 12:19:25 +0100

> Add initial support for tracking of wake-line status so we at any tim=
e
> know when we have a timer running and HSI wake-line high.
>=20
> The cfhsi_notify_rx, and cfhsi_wakeline_aquired/released are
> dummies for now.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Magic unused ifdefs and empty methods for a new feature not even
implemented.

No thanks on both counts.

I'm not applying this.
