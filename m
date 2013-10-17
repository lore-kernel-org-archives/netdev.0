From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-10-13
Date: Thu, 17 Oct 2013 14:27:40 -0400 (EDT)
Message-ID: <20131017.142740.1144850877979986678.davem@davemloft.net>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758168Ab3JQS1m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 14:27:42 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <antonio@meshcoding.com>
Date: Sun, 13 Oct 2013 13:22:45 +0200

> this is our second pull request intended for net-next/linux-3.13.
>=20
> The most important piece in this patchset is the new packet fragmenta=
tion code
> implemented by Martin Hundeb=F8ll during his Google Summer of Code 20=
12[1]. This
> code is entirely substituting the current fragmentation mechanism.
>=20
> Other than this you have:
> - the creation of a common BAT ICMP header which makes the ICMP subsy=
stem more
>   flexible and extensible
> - the addition of a dummy rx mode handler for the soft-interface whic=
h allows
>   users to set static multicast listeners
> - some minor improvements and code cleanups
>=20
>=20
> Please pull or let me know of any problem.

Pulled, thanks Antonio.
