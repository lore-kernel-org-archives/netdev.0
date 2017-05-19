From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] ah: use crypto_memneq to check the ICV
Date: Fri, 19 May 2017 15:24:44 +0200
Message-ID: <20170519132444.GK22049@secunet.com>
References: <c53afb48648b2727f6272053f6100c8db3ec6486.1493741168.git.sd@queasysnail.net>
 <20170504104124.GV2649@secunet.com>
 <20170519122514.GA3559@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37238 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752594AbdESNYr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 09:24:47 -0400
Content-Disposition: inline
In-Reply-To: <20170519122514.GA3559@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 02:25:14PM +0200, Sabrina Dubroca wrote:
> Hi Steffen,
> 
> 2017-05-04, 12:41:24 +0200, Steffen Klassert wrote:
> > On Wed, May 03, 2017 at 04:57:57PM +0200, Sabrina Dubroca wrote:
> > > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > > ---
> > >  net/ipv4/ah4.c | 5 +++--
> > >  net/ipv6/ah6.c | 5 +++--
> > >  2 files changed, 6 insertions(+), 4 deletions(-)
> > 
> > Is this a fix for something? If so, please describe what it fixes.
> > If not, it can wait until after the merge window and merged into
> > ipsec-next then.
> 
> Do you prefer that I resend the patch, or can you take it directly?

No need to resend, I've just applied it directly.

Thanks a lot Sabrina!
