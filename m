From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about MAC address change
Date: Sun, 23 Dec 2007 22:02:45 +0800
Message-ID: <E1J6RPh-0004mf-00@gondolin.me.apana.org.au>
References: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: dshwatrz@gmail.com (David Shwatrz)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1161 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750964AbXLWOC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 09:02:57 -0500
In-Reply-To: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz <dshwatrz@gmail.com> wrote:
> 
> Hi,
> Oop, I am TWICE sorry ! I wrongly attached a wrong, empty file.
> Attached here is the patch.
> 
> Regarding your answer;  I accept it and I will soon send a revised
> version of this patch (making changes to
> arp_netdev_event() and ndisc_netdev_event().)
> I had  IPv4 in mind, there is no reason that it will no be also in IPv6.

Hmm, why can't you do this from user-space?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
