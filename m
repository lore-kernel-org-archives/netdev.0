From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Sat, 5 Feb 2005 17:50:49 +1100
Message-ID: <20050205065049.GB29758@gondor.apana.org.au>
References: <20050131102920.GC4170@suse.de> <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au> <20050203142705.GA11318@krispykreme.ozlabs.ibm.com> <20050203150821.2321130b.davem@davemloft.net> <20050204113305.GA12764@gondor.apana.org.au> <20050204154855.79340cdb.davem@davemloft.net> <20050204222428.1a13a482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, okir@suse.de, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050204222428.1a13a482.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 04, 2005 at 10:24:28PM -0800, David S. Miller wrote:
> 
> Ok, as promised, here is the updated doc.  Who should

Looks good David.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
