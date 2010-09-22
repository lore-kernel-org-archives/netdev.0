From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] caif: Remove buggy re-definition of pr_debug
Date: Tue, 21 Sep 2010 18:07:17 -0700 (PDT)
Message-ID: <20100921.180717.115936981.davem@davemloft.net>
References: <1285101606-2264-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755919Ab0IVBG5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 21:06:57 -0400
In-Reply-To: <1285101606-2264-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: sjur.brandeland@stericsson.com
Date: Tue, 21 Sep 2010 22:40:06 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
>=20
> Remove debugging quirk redefining pr_debug to pr_warning.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> ---
>=20
> Hi Dave,
> I don't know if this qualify for going to 2.6.36.
> It's not really a serious bug, but it would be
> nice to get it fixed.

Not appropriate for net-2.6, applied to net-next-2.6 instead.

Thanks.
