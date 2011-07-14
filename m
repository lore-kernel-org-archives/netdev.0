From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/10] net: vlan: remove reduntant check in
 ndo_fix_features callback
Date: Thu, 14 Jul 2011 14:39:47 -0700 (PDT)
Message-ID: <20110714.143947.864001920590634958.davem@davemloft.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<909c4963df5c6dfa289e84f0133dddd5bd95b194.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab1GNVlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 17:41:55 -0400
In-Reply-To: <909c4963df5c6dfa289e84f0133dddd5bd95b194.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)

> Use the fact that ORing with zero is a no-op.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied, I was going to suggest this when Shan Wei's bug fix went
in :-)
