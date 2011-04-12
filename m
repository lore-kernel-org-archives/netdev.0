From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bna: convert to hw_features
Date: Tue, 12 Apr 2011 14:52:59 -0700 (PDT)
Message-ID: <20110412.145259.102551828.davem@davemloft.net>
References: <20110412193823.177C613A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rmody@brocade.com, ddutt@brocade.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932097Ab1DLVxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:53:35 -0400
In-Reply-To: <20110412193823.177C613A64@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 12 Apr 2011 21:38:23 +0200 (CEST)

> Note: looks like bnad->conf_mutex is duplicating rtnl_lock.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
