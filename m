From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen: netfront: ethtool stats fields should be unsigned
 long
Date: Mon, 14 Mar 2011 21:06:15 -0700 (PDT)
Message-ID: <20110314.210615.193717284.davem@davemloft.net>
References: <1299776658-15137-1-git-send-email-ian.campbell@citrix.com>
	<20110314.151029.200378268.davem@davemloft.net>
	<1300161043.2649.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org, jeremy@goop.org,
	bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37693
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750734Ab1COEFh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 00:05:37 -0400
In-Reply-To: <1300161043.2649.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Mar 2011 04:50:43 +0100

> Le lundi 14 mars 2011 =E0 15:10 -0700, David Miller a =E9crit :
>> From: Ian Campbell <ian.campbell@citrix.com>
>> Date: Thu, 10 Mar 2011 17:04:18 +0000
>>=20
>> > Fixup the rx_gso_checksum_fixup field added in e0ce4af920eb to be
>> > unsigned long as suggested by Ben Hutchings in
>> > <1298919198.2569.14.camel@bwh-desktop>
>> >=20
>> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
>>=20
>> Applied, thanks Ian.
>=20
> Hmm, this needs this followup patch then.
>=20
> Thanks
>=20
> [PATCH] xen: netfront: fix xennet_get_ethtool_stats()
>=20
> commit e9a799ea4a5551d2 (xen: netfront: ethtool stats fields should b=
e
> unsigned long) made rx_gso_checksum_fixup an unsigned long.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I even saw your feedback but for some reason I still applied
his patch, sorry about that :-)

Applied, thanks.
