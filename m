From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [NET]: Update frag_list in pskb_trim
Date: Thu, 3 Aug 2006 00:19:00 -0700
Message-ID: <20060803071900.GM26354@kroah.com>
References: <20060713090341.GA28426@gondor.apana.org.au> <20060713.220526.55726160.davem@davemloft.net> <20060715001003.GD9334@gondor.apana.org.au> <20060717152244.GA2174@kroah.com> <20060717181329.GA5934@gondor.apana.org.au> <20060730225037.GA21685@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stable@kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:9868 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932363AbWHCHX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 03:23:28 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060730225037.GA21685@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 08:50:37AM +1000, Herbert Xu wrote:
> For stable only:
> 
> On Tue, Jul 18, 2006 at 04:13:29AM +1000, herbert wrote:
> > 
> > Here is a second attempt:
> > 
> > [NET]: Update frag_list in pskb_trim
> 
> Unfortunately there was a bug in the fix which is now fixed.  I presume
> this hasn't been included yet so I'm simply regenerating the whole patch.
> Let me know if you want an incremental version instead.
> 
> [NET]: Update frag_list in pskb_trim


Queued to -stable.

thanks,

greg k-h

