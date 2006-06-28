From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [NET]: Added GSO header verification
Date: Tue, 27 Jun 2006 19:07:24 -0700
Message-ID: <1151460444.5124.2.camel@rh4>
References: <20060627120714.GA15270@gondor.apana.org.au>
 <1151441195.3543.3.camel@rh4>
 <20060627223120.GA19026@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:54799 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030245AbWF1CGZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 22:06:25 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060627223120.GA19026@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 08:31 +1000, Herbert Xu wrote:

> [NET]: Fix logical error in skb_gso_ok
> 
> The test in skb_gso_ok is backwards.  Noticed by Michael Chan
> <mchan@broadcom.com>.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Michael Chan <mchan@broadcom.com>

