From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: sched: constify tcf_proto and tc_action
Date: Wed, 06 Jul 2011 03:05:46 -0700 (PDT)
Message-ID: <20110706.030546.1942580411751220001.davem@davemloft.net>
References: <20110705.225633.2168272736556352902.davem@davemloft.net>
	<20110705.225921.2065481038863776818.davem@davemloft.net>
	<1309944342.2292.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab1GFKFv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 06:05:51 -0400
In-Reply-To: <1309944342.2292.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jul 2011 11:25:42 +0200

> Le mardi 05 juillet 2011 =E0 22:59 -0700, David Miller a =E9crit :
>=20
>> BTW, is is really so hard for people to do "allmodconfig"
>> builds?
>>=20
>> You can take your chances the first time, but if you need to respin
>> because of warnings and breakage, the onus is on you to actually do =
a
>> real complete build regression test on your changes.
>>=20
>> I shouldn't be the one hitting this stuff, you folks should.
>=20
> Yes my bad, sorry David, I hope this one is OK.
>=20
> [PATCH v3] net: sched: constify tcf_proto and tc_action
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Yep, this one passed :-)  Applied, thanks.
