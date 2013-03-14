From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-03-13
Date: Thu, 14 Mar 2013 11:48:12 -0400 (EDT)
Message-ID: <20130314.114812.1928545478791651343.davem@davemloft.net>
References: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933909Ab3CNPr6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:47:58 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 13 Mar 2013 23:56:30 +0100

> here you have our first patchset intended for net-next/linux-3.10.
>=20
> These patches include a new big component implementing a first versio=
n of
> Network Coding for mesh networks. This code is the result of Martin H=
undeb=F8ll
> and Jeppe Ledet-Pedersen's Master Thesis[1]. The target of Network Co=
ding is to
> increase throughput by fusing multiple packets in one wifi transmissi=
on (thus
> saving airtime).
> This new component also introduced a new Kbuild option which can be u=
sed to
> decide whether to include this feature or not. However, a switch to d=
ynamically
> turn off the behaviour at runtime has been provided too. DebugFS has =
also been
> extended with some knobs to be used in case of debugging only.
>=20
> The rest is clean up work.

Pulled, thanks Antonio.
