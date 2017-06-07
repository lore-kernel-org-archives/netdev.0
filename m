From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2 2/2] xfrm: add UDP encapsulation port in migrate
 message
Date: Wed, 7 Jun 2017 13:02:33 +0200
Message-ID: <20170607110233.GW2631@secunet.com>
References: <20170605215625.11043-1-antony@phenome.org>
 <1496743934-12697-2-git-send-email-antony@phenome.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Richard Guy Briggs <rgb@tricolour.ca>
To: Antony Antony <antony@phenome.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35626 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751742AbdFGLCg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 07:02:36 -0400
Content-Disposition: inline
In-Reply-To: <1496743934-12697-2-git-send-email-antony@phenome.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 06, 2017 at 12:12:14PM +0200, Antony Antony wrote:
> Add XFRMA_ENCAP, UDP encapsulation port, to km_migrate announcement
> to userland. Only add if XFRMA_ENCAP was in user migrate request.
> 
> Signed-off-by: Antony Antony <antony@phenome.org>
> Reviewed-by: Richard Guy Briggs <rgb@tricolour.ca>

Both patches applied to ipsec-next, thanks a lot!
