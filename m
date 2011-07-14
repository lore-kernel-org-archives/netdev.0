From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] net: remove NETIF_F_ALL_TX_OFFLOADS
Date: Thu, 14 Jul 2011 14:58:57 -0700 (PDT)
Message-ID: <20110714.145857.1611970250010658023.davem@davemloft.net>
References: <7750f18707f8ebc674a830555b0227c49cbfd608.1310601401.git.mirq-linux@rere.qmqm.pl>
	<20110714.144314.1353889855984029341.davem@davemloft.net>
	<20110714215401.GA17618@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524Ab1GNWBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 18:01:07 -0400
In-Reply-To: <20110714215401.GA17618@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 23:54:01 +0200

> I agree about the fallbacks, but this patch is about fixing a regress=
ion
> that's going to hit 3.0. Now all bonding devices always advertise e.g=
=2E
> SCTP_CSUM. Sorry if I was unclear about this.

Why are you mixing cleanups and bug fixes?

