From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 0/4] xfrm_user info leaks
Date: Tue, 29 Aug 2017 06:43:45 +0200
Message-ID: <20170829044345.GD3311@secunet.com>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
 <20170828.155232.1540318133719787999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <minipli@googlemail.com>, <herbert@gondor.apana.org.au>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39208 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750758AbdH2Ens (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 00:43:48 -0400
Content-Disposition: inline
In-Reply-To: <20170828.155232.1540318133719787999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 03:52:32PM -0700, David Miller wrote:
> From: Mathias Krause <minipli@googlemail.com>
> Date: Sat, 26 Aug 2017 17:08:56 +0200
> 
> > Hi David, Steffen,
> > 
> > the following series fixes a few info leaks due to missing padding byte
> > initialization in the xfrm_user netlink interface.
> > 
> > Please apply!
> 
> Steffen please pick this up if you haven't already.

I had it already in the ipsec/testing branch, now merged into
ipsec/master.

Thanks everyone!
