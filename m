From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gro: refetch inet6_protos[] after pulling ext headers
Date: Mon, 10 Oct 2011 14:26:40 -0400 (EDT)
Message-ID: <20111010.142640.1539695624934735900.davem@davemloft.net>
References: <4E915C9B.4000807@intel.com>
	<1318152831.5276.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zheng.z.yan@intel.com, netdev@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab1JJS0t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 14:26:49 -0400
In-Reply-To: <1318152831.5276.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Oct 2011 11:33:51 +0200

> Le dimanche 09 octobre 2011 =E0 16:34 +0800, Yan, Zheng a =E9crit :
>> ipv6_gro_receive() doesn't update the protocol ops after pulling
>> the ext headers. It looks like a typo.
>>=20
>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
 ...
>=20
> Good catch !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!
