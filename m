From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/9] nftables: reject NFT_SET_ELEM_INTERVAL_END flag for
 non-interval sets
Date: Fri, 30 Jan 2015 19:00:21 +0100
Message-ID: <20150130180021.GA12318@salvia>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-3-git-send-email-kaber@trash.net>
 <20150130173107.GA9243@salvia>
 <20150130175525.GA8670@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, davem@davemloft.net,
	David.Laight@ACULAB.COM, ying.xue@windriver.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150130175525.GA8670@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2015 at 05:55:26PM +0000, Patrick McHardy wrote:
> On 30.01, Pablo Neira Ayuso wrote:
> > Hi Patrick,
> > 
> > Unless you have any concern, I'm going to apply this and 8/9 to
> > nf-next, so you don't need to resend these two sanitization fixes.
> 
> This one is not needed for mainline so far since nft_hash validates
> on its own. It is only required since my series centralizes that
> validation once the set extensions are added.
> 
> For 8/9, sure.

OK, I'll take 8/9 then, thanks!
