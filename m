From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibmveth: convert to hw_features
Date: Wed, 20 Apr 2011 01:32:03 -0700 (PDT)
Message-ID: <20110420.013203.260080965.davem@davemloft.net>
References: <20110419121426.18A2D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, santil@linux.vnet.ibm.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55423
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752211Ab1DTIch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:32:37 -0400
In-Reply-To: <20110419121426.18A2D13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 14:14:25 +0200 (CEST)

> A minimal conversion.
>=20
> ibmveth_set_csum_offload() can be folded into ibmveth_set_features()
> and adapter->rx_csum removed - left for later cleanup.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
