From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] caif-hsi: Fix merge issues.
Date: Fri, 29 Jun 2012 00:48:20 -0700 (PDT)
Message-ID: <20120629.004820.1610791486901428775.davem@davemloft.net>
References: <1340951780-27406-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab2F2HsX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 03:48:23 -0400
In-Reply-To: <1340951780-27406-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: sjur.brandeland@stericsson.com
Date: Fri, 29 Jun 2012 08:36:20 +0200

> From: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
>=20
> Fix the failing merge in net-next by reverting the last
> net-next merge for caif_hsi.c and then merge in the commit:
> "caif-hsi: Bugfix - Piggyback'ed embedded CAIF frame lost"
> from the net repository.=20
>=20
> The commit:"caif-hsi: Add missing return in error path" from
> net repository was dropped, as it changed code previously removed in =
the=20
> net-next repository.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied, thanks a lot.
