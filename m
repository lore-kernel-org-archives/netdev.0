From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] pktgen: refactor pg_init() code
Date: Sun, 22 May 2011 21:02:10 -0400 (EDT)
Message-ID: <20110522.210210.1533356691217219621.davem@davemloft.net>
References: <BANLkTikd8Ft0N6ovGp8KOVksg2Rj4RxRaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab1EWBCO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:02:14 -0400
In-Reply-To: <BANLkTikd8Ft0N6ovGp8KOVksg2Rj4RxRaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Am=E9rico Wang <xiyou.wangcong@gmail.com>
Date: Sun, 22 May 2011 18:52:08 +0800

> This also shrinks the object size a little.
>=20
>    text	   data	    bss	    dec	    hex	filename
>   28834	    186	      8	  29028	   7164	net/core/pktgen.o
>   28816	    186	      8	  29010	   7152	net/core/pktgen.o.AFTER
>=20
>=20
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: "David Miller" <davem@davemloft.net>,

Applied.
