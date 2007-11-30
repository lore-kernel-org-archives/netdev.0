From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] AF_RXRPC: Configure crypto correctly for AF_RXRPC
Date: Fri, 30 Nov 2007 13:11:47 +0100
Message-ID: <20071130121147.GB2665@elte.hu>
References: <20071128143753.15234.29444.stgit@warthog.procyon.org.uk> <20071130120716.GB26848@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:46495 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357AbXK3MMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 07:12:07 -0500
Content-Disposition: inline
In-Reply-To: <20071130120716.GB26848@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Nov 28, 2007 at 02:37:53PM +0000, David Howells wrote:
> > AF_RXRPC uses the crypto services, so should depend on or select CRYPTO.
> > 
> > Signed-off-by: David Howells <dhowells@redhat.com>
> 
> Patch applied to net-2.6.  Thanks.

aimed at 2.6.24 merging, right?

	Ingo
