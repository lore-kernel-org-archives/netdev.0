From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vmxnet3: convert to hw_features
Date: Mon, 18 Apr 2011 23:04:59 -0700 (PDT)
Message-ID: <20110418.230459.48516860.davem@davemloft.net>
References: <20110418233121.AEC4913A68@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com,
	pv-drivers@vmware.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60225
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752493Ab1DSGFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 02:05:33 -0400
In-Reply-To: <20110418233121.AEC4913A68@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 01:31:21 +0200 (CEST)

> This also removes private feature flags that were always set to true.
>=20
> You may want to move vmxnet3_set_features() to vmxnet3_drv.c as a fol=
lowing
> cleanup.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
