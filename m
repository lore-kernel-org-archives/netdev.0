From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: rename local_df to ignore_df
Date: Wed, 07 May 2014 15:30:14 -0400 (EDT)
Message-ID: <20140507.153014.491918803207368640.davem@davemloft.net>
References: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com, fw@strlen.de,
	eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaEGTaQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:30:16 -0400
In-Reply-To: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sun,  4 May 2014 16:39:18 -0700

> As suggested by several people, rename local_df to ignore_df,
> since it means "ignore df bit if it is set".
>=20
> Cc: Maciej =AFenczykowski <maze@google.com>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I'll apply this the next time I merge net into net-next in order to dea=
l
with the conflict with Florian's bug fixes more easily.

Thanks.
