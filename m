From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: af_packet & CHECKSUM_HW
Date: Sat, 15 Nov 2003 13:44:34 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031115024434.GA12276@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi:

Should the packet socket compute the checksums of CHECKSUM_HW packets
before sending them to userspace?

In other words, what do I tell confused users who see bad checksums
in the tcpdump output over loopback and interfaces capable of
hardware checksums?

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
