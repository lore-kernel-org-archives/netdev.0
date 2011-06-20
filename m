From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar v5: implement nfc
Date: Mon, 20 Jun 2011 13:58:08 -0700 (PDT)
Message-ID: <20110620.135808.1686703771592664461.davem@davemloft.net>
References: <1308562782.12794.6.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sebastian.poehn@belden.com, joe@perches.com
To: sebastian.belden@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284Ab1FTU6R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:58:17 -0400
In-Reply-To: <1308562782.12794.6.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Sebastian P=F6hn" <sebastian.belden@googlemail.com>
Date: Mon, 20 Jun 2011 11:39:42 +0200

> This patch adds all missing functionalities for nfc except GRXFH. The=
re is so much code because hardware has not a TCAM.
> Further hardware rule space is very limited. So I had to extensively =
use
> optimization features. Both reasons lead to the necessity to hold all
> online flows in a linked-list.
>=20
> Change-log:
> # Some suggestions by Joe Perches applied (thanks!)
> # Shorted some logs
> # Use memcmp() for comparing
>=20
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

Applied, thanks.
