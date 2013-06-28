From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/2] xfrm/af_key constify patches
Date: Fri, 28 Jun 2013 10:50:22 +0200
Message-ID: <20130628085022.GF3109@secunet.com>
References: <1372283819-30012-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33564 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720Ab3F1IuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 04:50:25 -0400
Content-Disposition: inline
In-Reply-To: <1372283819-30012-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 11:56:57PM +0200, Mathias Krause wrote:
> Hi Steffen,
> 
> two small patches, constifying af_key lookup tables and a xfrm function
> argument. All material for ipsec-next.
> 
> Please apply!
> 
> Thanks,
> 
> Mathias Krause (2):
>   xfrm: constify mark argument of xfrm_find_acq()
>   af_key: constify lookup tables
> 

All applied to ipsec-next, thanks!
