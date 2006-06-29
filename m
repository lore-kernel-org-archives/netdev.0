From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Added GSO header verification
Date: Thu, 29 Jun 2006 12:26:10 -0700 (PDT)
Message-ID: <20060629.122610.07637917.davem@davemloft.net>
References: <1151441195.3543.3.camel@rh4>
	<20060627223120.GA19026@gondor.apana.org.au>
	<1151460444.5124.2.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23208
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932298AbWF2T0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 15:26:11 -0400
To: mchan@broadcom.com
In-Reply-To: <1151460444.5124.2.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 27 Jun 2006 19:07:24 -0700

> On Wed, 2006-06-28 at 08:31 +1000, Herbert Xu wrote:
> 
> > [NET]: Fix logical error in skb_gso_ok
> > 
> > The test in skb_gso_ok is backwards.  Noticed by Michael Chan
> > <mchan@broadcom.com>.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks a lot guys.
