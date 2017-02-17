From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: pull request (net-next): ipsec-next 2017-02-16
Date: Fri, 17 Feb 2017 10:52:00 +0100
Message-ID: <20170217095200.GB30338@gauss.secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
 <20170216.220557.990082216928137722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44582 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933304AbdBQJwR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 04:52:17 -0500
Content-Disposition: inline
In-Reply-To: <20170216.220557.990082216928137722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 10:05:57PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 16 Feb 2017 13:18:34 +0100
> > 
> > Please note that this has a merge coflict between commit
> > 
> > 63fca65d0863 ("net: add confirm_neigh method to dst_ops")
> > 
> > from net-next and
> > 
> > 3d7d25a68ea5 ("xfrm: policy: remove garbage_collect callback")
> > a2817d8b279b ("xfrm: policy: remove family field")
> > 
> > from ipsec-next.
> > 
> > The conflict can be solved as it is done in linux-next.
> > 
> > Please pull or let me know if there are problems.
> 
> Pulled, thanks.  Please double check that I did the merge conflict
> resolution properly.

The resolution is correct, thanks!
