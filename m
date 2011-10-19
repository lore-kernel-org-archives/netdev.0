From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_rules: fix unresolved_rules counting
Date: Wed, 19 Oct 2011 19:18:11 -0400 (EDT)
Message-ID: <20111019.191811.522536811169576358.davem@davemloft.net>
References: <4E9CD45C.9050608@intel.com>
	<1318909651.2571.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zheng.z.yan@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab1JSXS0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 19:18:26 -0400
In-Reply-To: <1318909651.2571.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Oct 2011 05:47:31 +0200

> Le mardi 18 octobre 2011 =E0 09:20 +0800, Yan, Zheng a =E9crit :
>> we should decrease ops->unresolved_rules when deleting a unresolved =
rule.
>>=20
>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
 ...
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
