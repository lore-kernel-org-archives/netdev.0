From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Mon, 22 Sep 2008 13:36:24 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809221329140.1034@wrl-59.cs.helsinki.fi>
References: <20080920.125949.193703969.davem@davemloft.net>
 <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au> <20080920.235727.247411045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, dwalker@mvista.com,
	arjan@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35017 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbYIVKg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 06:36:29 -0400
In-Reply-To: <20080920.235727.247411045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Sep 2008, David Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 21 Sep 2008 15:05:45 +0900
> 
> > Of course, we need to balance any effort spent on this with the
> > likelihood that hardware improvements will soon make this obsolete
> > (for IPsec anyway).
> 
> True, but old hardware will always exist.

...Also, producing buggy hardware will not suddently just vanish either 
("can you please turn of ipsec offloading and see if you can still
reproduce" :-))...

-- 
 i.
