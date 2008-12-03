From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not
 respected
Date: Wed, 03 Dec 2008 00:36:36 -0800 (PST)
Message-ID: <20081203.003636.114008977.davem@davemloft.net>
References: <1227719692.13189.7.camel@HP1>
	<1228173819.15505.15.camel@HP1>
	<4934D000.5000304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750951AbYLCNYY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 08:24:24 -0500
In-Reply-To: <4934D000.5000304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 02 Dec 2008 07:04:48 +0100

> Michael Chan a =E9crit :
> > [PATCH] bnx2: Add workaround to handle missed MSI.
 ...
> Thanks a lot Michael
>=20
> I tested your patch on my machine.
>=20
> I confirm CPU unplug/hotplug works now (If correcting a bug in oprofi=
le first)
> NIC doesnt freeze anymore

Applied to net-2.6, thanks everyone.
