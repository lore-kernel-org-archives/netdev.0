From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: remove unused struct xfrm_mgr::id
Date: Mon, 27 Mar 2017 12:35:47 +0200
Message-ID: <20170327103547.GF23004@secunet.com>
References: <20170323222940.GB31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39930 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752246AbdC0KhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 06:37:25 -0400
Content-Disposition: inline
In-Reply-To: <20170323222940.GB31372@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 01:29:40AM +0300, Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  include/net/xfrm.h   |    1 -
>  net/key/af_key.c     |    1 -
>  net/xfrm/xfrm_user.c |    1 -
>  3 files changed, 3 deletions(-)

Applied to ipsec-next, thanks!
