From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Unable to halt or reboot due to - unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1
Date: Fri, 01 Sep 2006 20:41:35 +1000
Message-ID: <E1GJ6St-0004Te-00@gondolin.me.apana.org.au>
References: <9a8748490609010259l7c42ca88tbcc87410a770b48c@mail.gmail.com>
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	waltje@uwalt.nl.mugnet.org, ross.biro@gmail.com,
	davem@davemloft.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32015 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751438AbWIAKmN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 06:42:13 -0400
To: jesper.juhl@gmail.com (Jesper Juhl)
In-Reply-To: <9a8748490609010259l7c42ca88tbcc87410a770b48c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl <jesper.juhl@gmail.com> wrote:
>
> I've just encountered the problem on a different server with an
> identical vlan setup. That server is running 2.6.13.4

Do you have a simple recipe to reproduce this? Ideally it'd be a
script that anyone can execute in a freshly booted system that
exhibits the problem.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
