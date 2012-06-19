From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2012-06-18
Date: Mon, 18 Jun 2012 20:28:55 -0700 (PDT)
Message-ID: <20120618.202855.272613444878909098.davem@davemloft.net>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110Ab2FSD25 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 23:28:57 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <ordex@autistici.org>
Date: Mon, 18 Jun 2012 22:39:04 +0200

> Hello David,
> 	here is our first set of changes intended for next-next/linux-3.6.
>=20
> Patch 2 fixes a major bug in the TranslationTable code where the old =
value of
> skb->data is used for memory access even if the data was relocated.
> Patches 4, 10, 11, 13, 14 are endianess-related cleanups that we wrot=
e thanks
> to Al Viro's advice and help.
> Thanks to Martin Hundeb=F8ll batman-adv now supports the ethtool API =
and can
> export several counters that are specific to our module (patch 5).
> Then patch 16 improves the routing protocol API by making part of the
> TranslationTable code routing agnostic.
> The rest are minor fixes and other cleanups.

Pulled, thanks.
