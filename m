From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/3] caif-hsi: Bugfix - Piggyback'ed embedded CAIF frame
 lost
Date: Mon, 25 Jun 2012 16:07:39 -0700 (PDT)
Message-ID: <20120625.160739.812510532952613057.davem@davemloft.net>
References: <1340571698-17892-1-git-send-email-sjur.brandeland@stericsson.com>
	<1340571698-17892-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	Per.Ellefsen@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857Ab2FYXHk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:07:40 -0400
In-Reply-To: <1340571698-17892-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: sjur.brandeland@stericsson.com
Date: Sun, 24 Jun 2012 23:01:37 +0200

> From: Per Ellefsen <Per.Ellefsen@stericsson.com>
>=20
> When receiving a piggyback'ed descriptor containing an
> embedded frame, but no payload, the embedded frame was
> lost.
>=20
> Signed-off-by: Per Ellefsen <per.ellefsen@stericsson.com>
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
