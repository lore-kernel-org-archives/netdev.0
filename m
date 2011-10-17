From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 5/5] igbvf: convert to ndo_fix_features
Date: Sun, 16 Oct 2011 22:25:14 -0400 (EDT)
Message-ID: <20111016.222514.2075714622931839689.davem@davemloft.net>
References: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1318797423-19897-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<20111016220819.GA25318@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab1JQCZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 22:25:22 -0400
In-Reply-To: <20111016220819.GA25318@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Mon, 17 Oct 2011 00:08:19 +0200

> Great news!
>=20
> This is the last brick needed for ethtool cleanup. After Dave takes t=
his
> one in I'll start dusting off the patches that introduce netif_featur=
es_t
> and extend it to 64 bits.

=46eel free to start doing this now.
