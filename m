From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vxge: convert to hw_features
Date: Mon, 18 Apr 2011 23:05:05 -0700 (PDT)
Message-ID: <20110418.230505.260100099.davem@davemloft.net>
References: <20110418233121.5D8BB13A66@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jdmason@kudzu.us
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752269Ab1DSGFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 02:05:39 -0400
In-Reply-To: <20110418233121.5D8BB13A66@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 01:31:21 +0200 (CEST)

> Side effect: ->gro_enable is removed as napi_gro_receive() does the
> fallback itself.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
