From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: Divide Error in tcp_set_skb_tso_segs
Date: Mon, 22 Nov 2004 19:32:24 +1100
Message-ID: <20041122083224.GA27137@gondor.apana.org.au>
References: <E1CW8VH-0006wt-00@gondolin.me.apana.org.au> <Pine.GSO.4.58.0411220209110.29499@unix.cs.tamu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Erik Mckee <emckee@cs.tamu.edu>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.58.0411220209110.29499@unix.cs.tamu.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 22, 2004 at 02:09:55AM -0600, Erik Mckee wrote:
> This is 2.6.10-rc1, I am sorry for the double typo.  Should I try to
> upgrade to 2.6.10-rc2 first?

Yes please.  In fact the very first change after 2.6.10-rc1 was released
should fix your problem :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
