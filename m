From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: qlcnic: convert to hw_features
Date: Wed, 20 Apr 2011 01:32:10 -0700 (PDT)
Message-ID: <20110420.013210.246539449.davem@davemloft.net>
References: <20110419124238.AECB513909@rere.qmqm.pl>
	<20110419130357.40FA813909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, amit.salecha@qlogic.com,
	anirban.chakraborty@qlogic.com, linux-driver@qlogic.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752453Ab1DTIcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:32:45 -0400
In-Reply-To: <20110419130357.40FA813909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 15:03:57 +0200 (CEST)

> Bit more than minimal conversion. There might be some issues because
> of qlcnic_set_netdev_features() if it's called after netdev init.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> ---
> v2: fix compilation issues (I forgot to 'stg refresh' before sending =
v1)

Applied.
