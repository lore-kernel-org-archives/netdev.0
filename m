From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: implement dev_disable_lro() hw_features
 compatibility
Date: Tue, 22 Mar 2011 01:00:50 -0700 (PDT)
Message-ID: <20110322.010050.241932002.davem@davemloft.net>
References: <1300471986.2589.26.camel@bwh-desktop>
	<32d98168b9b4ae553cc3647c30da85be05a28c95.1300503092.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754934Ab1CVIAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 04:00:12 -0400
In-Reply-To: <32d98168b9b4ae553cc3647c30da85be05a28c95.1300503092.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat, 19 Mar 2011 03:56:34 +0100 (CET)

> Implement compatibility with new hw_features for dev_disable_lro().
> This is a transition path - dev_disable_lro() should be later
> integrated into netdev_fix_features() after all drivers are converted=
=2E
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

I'll apply this, thanks.
