From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] net: cleanup vlan_features setting in
 register_netdev
Date: Thu, 14 Jul 2011 14:41:19 -0700 (PDT)
Message-ID: <20110714.144119.150144248449516465.davem@davemloft.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<27c1ec41217c615f63183b53bb1d5eccff08b9f8.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801Ab1GNVm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 17:42:26 -0400
In-Reply-To: <27c1ec41217c615f63183b53bb1d5eccff08b9f8.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)

> vlan_features contains features inherited from underlying device.
> NETIF_SOFT_FEATURES are not inherited but belong to the vlan device
> itself (ensured in vlan_dev_fix_features()).
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
