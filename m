From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the crypto tree with the net-next
 tree
Date: Wed, 9 Mar 2016 08:22:44 +1100
Message-ID: <20160309082244.621bb27c@canb.auug.org.au>
References: <20160308165612.54c8dd50@canb.auug.org.au>
	<20160307131834.70da82d4@canb.auug.org.au>
	<28626.1457348905@warthog.procyon.org.uk>
	<13171.1457455687@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <13171.1457455687@warthog.procyon.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Tue, 08 Mar 2016 16:48:07 +0000 David Howells <dhowells@redhat.com> wrote:
>
> Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> 
> > > What's the best way to deal with this?  Should I take Herbert's
> > > 
> > > 	[PATCH 18/26] rxrpc: Use skcipher
> > > 
> > > patch into my rxrpc tree also and pass it on to Dave?  
> > 
> > Linus can deal with it when he merges the latter of the crypto or
> > net-next trees.  It might be worth a mention in the respective pull
> > requests.  
> 
> Do you mean I should take it - or just let Linus merge it?

Just leave it to Linus.

-- 
Cheers,
Stephen Rothwell
