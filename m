From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bonding: enhance the IP address check of arp_ip_target
Date: Wed, 12 Jul 2006 15:19:59 +1000
Message-ID: <E1G0X8h-0003Tg-00@gondolin.me.apana.org.au>
References: <20060711215317.7d673f89@localhost.localdomain>
Cc: takata.tetsuo@oss.ntt.co.jp, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, takatatt@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39175 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751288AbWGLFUa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 01:20:30 -0400
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060711215317.7d673f89@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> Why not just use sscanf?

Better yet, use a better interface like netlink rather than module
parameters.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
