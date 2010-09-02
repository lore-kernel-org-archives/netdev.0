From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: arp: code cleanup
Date: Wed, 01 Sep 2010 18:29:45 -0700
Message-ID: <1283390985.1797.256.camel@Joe-Laptop>
References: <1283385110-2953-1-git-send-email-xiaosuo@gmail.com>
	 <20100901.175712.199039832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1220 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab0IBB3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 21:29:47 -0400
In-Reply-To: <20100901.175712.199039832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-01 at 17:57 -0700, David Miller wrote:
> [comments] should always be written as:
> 
> 	/* A comment
> 	 * looks like this.
> 	 */
> 
> in any patch you want me to apply in the networking.

/*
 * multiline comment
 * style 1
 */

vs

/* multiline comment
 * style 2
 */

Style 1 vs style 2 in drivers/net: (13600/13785)
Style 1 vs style 2 in net: (6801/5114)

Style 1 is recommended in Documentation/CodingStyle.


