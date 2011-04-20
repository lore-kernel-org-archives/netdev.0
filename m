From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pch_gbe: convert to hw_features
Date: Wed, 20 Apr 2011 01:31:54 -0700 (PDT)
Message-ID: <20110420.013154.48495545.davem@davemloft.net>
References: <20110419115612.C83881389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, toshiharu-linux@dsn.okisemi.com,
	masa-korg@dsn.okisemi.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752135Ab1DTIc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:32:28 -0400
In-Reply-To: <20110419115612.C83881389B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 13:56:12 +0200 (CEST)

> This also fixes bug in xmit path, where TX checksum offload state was=
 used
> instead of skb->ip_summed to decide if the offload was needed.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
