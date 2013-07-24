From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip6mr: change the prototype of
 ip6_mr_forward().
Date: Tue, 23 Jul 2013 17:21:00 -0700 (PDT)
Message-ID: <20130723.172100.861888744953479475.davem@davemloft.net>
References: <1374364831-13190-1-git-send-email-ramirose@gmail.com>
	<51ED9A7A.1010008@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ramirose@gmail.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab3GXAVB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 20:21:01 -0400
In-Reply-To: <51ED9A7A.1010008@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 22 Jul 2013 22:47:54 +0200

> Le 21/07/2013 02:00, Rami Rosen a =E9crit :
>> This patch changes the prototpye of the ip6_mr_forward() method to
>> return void
>> instead of int.
>>
>> The ip6_mr_forward() method always returns 0; moreover, the return
>> value of this
>> method is not checked anywhere.
>>
>> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
