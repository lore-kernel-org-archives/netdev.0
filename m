From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 26 Dec 2004 16:36:23 +1100
Message-ID: <E1CiR4p-0004vc-00@gondolin.me.apana.org.au>
References: <41C612BC.5070909@tpack.net>
Cc: hadi@cyberus.ca, thomas.spatzier@de.ibm.com, davem@davemloft.net,
        hasso@estpak.ee, herbert@gondor.apana.org.au, jgarzik@pobox.com,
        netdev@oss.sgi.com, paul@clubi.ie
Return-path: <netdev-bounce@oss.sgi.com>
To: tommy.christensen@tpack.net (Tommy Christensen)
In-Reply-To: <41C612BC.5070909@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen <tommy.christensen@tpack.net> wrote:
> 
> OK. So is this the recommendation for these pour souls?
> 
>  - Use a socket for each device.

Please show us your program first.  Then we can figure out
whether this is necessary or not.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
