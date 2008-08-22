From: Sascha Biberhofer <biberhofer@inode.at>
Subject: Re: Oops in authenc: 2.6.26.3
Date: Fri, 22 Aug 2008 11:05:23 +0200
Message-ID: <20080822090523.GA888@aeris>
References: <20080821083615.GA1971@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt LaPlante <kernel1@cyberdogtech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757950AbYHVJFn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080821083615.GA1971@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Sorry, I was skimping on memory and ended up calling a clobbered
> function pointer.
> 
> This patch should fix it.

Works like a charm, thanks for the quick fix. 

  Sascha Biberhofer
