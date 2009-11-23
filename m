From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v7 5/7 RFC] TCPCT part 1e: implement
 socket option TCP_COOKIE_TRANSACTIONS
Date: Mon, 23 Nov 2009 09:25:29 -0800
Message-ID: <1258997129.16503.71.camel@Joe-Laptop.home>
References: <4B06A1FF.8000202@gmail.com>	<4B06AC2C.3070102@gmail.com>
	 <20091120.092651.254794724.davem@davemloft.net> <4B08D967.80003@gmail.com>
	 <1258873848.16503.12.camel@Joe-Laptop.home>  <4B0A6EF3.8040302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1081 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593AbZKWRZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 12:25:24 -0500
In-Reply-To: <4B0A6EF3.8040302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-23 at 06:16 -0500, William Allen Simpson wrote:
> Therefore, it's plain as can be that this is just more jumping through
> arbitrary and capricious hoops that others are not required to follow.
> At *thousands* of examples, including in the tcp*.c files themselves, it
> really becomes obvious that that may be a personal preference of David,
> but is *not* a tree-wide or even a net-wide coding style.

It seems similar kernel source uses are mostly historic.

Relatively little new code is added with leading || or &&.
There is some in staging/, but it normally gets removed.

> So, I'll try again now, with the assurance that this is the final hoop.

Once more into the breach or men of few words are the best men?
I'll stop typing now...

