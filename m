From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Natsemi DP83815 driver spaming
Date: Tue, 1 May 2007 01:35:57 -0700
Message-ID: <20070501013557.75f5c582.akpm@linux-foundation.org>
References: <46365887.3010705@interia.pl>
	<20070430205522.abad2481.akpm@linux-foundation.org>
	<4636E970.3010602@interia.pl>
	<4636F90A.2070303@interia.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Mark Brown <broonie@sirena.org.uk>
To: =?UTF-8?B?UmFmYcWC?= Bilski <rafalbilski@interia.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:46233 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754698AbXEAIgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 04:36:14 -0400
In-Reply-To: <4636F90A.2070303@interia.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 01 May 2007 10:23:38 +0200 Rafa=C5=82 Bilski <rafalbilski@inter=
ia.pl> wrote:

> Hello again,
>=20
> I have downloaded DP83815 datasheet and I see that
> > eth0: Wake-up event 0x200000a
> means "broadcast received" and wakup on broadcast and=20
> unicast enabled.
> > eth0: Wake-up event 0x80000a
> Above means "unicast received" and wakup on broadcast=20
> and unicast enabled.
> I will try to check if disabling wakeup makes any difference.
>=20

Thanks.

You've removed all the cc's I added.  I put them back.  Please always d=
o
reply-to-all.


