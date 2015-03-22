From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] netfilter: preparatory patches for set extensions
Date: Sun, 22 Mar 2015 04:48:46 +0000
Message-ID: <20150322044846.GB31192@acer.localdomain>
References: <1426952290-18962-1-git-send-email-kaber@trash.net>
 <20150321230447.GA31869@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, davem@davemloft.net, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150321230447.GA31869@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.03, Herbert Xu wrote:
> On Sat, Mar 21, 2015 at 03:38:08PM +0000, Patrick McHardy wrote:
> > 
> > @Dave and Pablo: these patches apply on top of nf-next and a bunch
> > of patches I just sent to Pablo, but also need Herbert's recent
> > changes in net-next. Additionally I have more patches coming up
> > which depend on these changes. In order to simplify things, I'd
> > suggest to have the rhashtable change go through Pablo's tree if
> > you don't mind.
> 
> I have more patches (multiple rehashing) coming up that will
> conflict with this.

I have a set of about 30 patches myself which depend on this simple
one liner, so I'd appreciate if we can come to a quick resolution
here so I can continue merging them instead of redoing them every
second day.
