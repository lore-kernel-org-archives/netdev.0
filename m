From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 11:20:54 -0400
Message-ID: <20091030152054.GA7936@gondor.apana.org.au>
References: <fb7befa20910290843k12ab8ba6hbecb69bda8652ae0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Adayadil Thomas <adayadil.thomas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40309 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932322AbZJ3PUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 11:20:53 -0400
Content-Disposition: inline
In-Reply-To: <fb7befa20910290843k12ab8ba6hbecb69bda8652ae0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adayadil Thomas <adayadil.thomas@gmail.com> wrote:
> 
> If two connections have same 5 tuple, src ip, dst ip, src port, dst
> port, protocol(tcp/udp)
> but on different vlans (different vlan id), does the conntrack separate these ?

Probably not.  Patrick, can you confirm this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
