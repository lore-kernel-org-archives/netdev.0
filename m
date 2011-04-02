From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert sunhme/sungem network drivers to
 hw_features
Date: Fri, 01 Apr 2011 20:58:45 -0700 (PDT)
Message-ID: <20110401.205845.15246905.davem@davemloft.net>
References: <20110331110135.BDFF913A69@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752668Ab1DBD7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:59:22 -0400
In-Reply-To: <20110331110135.BDFF913A69@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)

> Side effects:
>  - TX offloads (HW csum, scatter-gather) can be toggled now
>  - RX checksum is reported correctly now (it's always active)
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied, thanks.
