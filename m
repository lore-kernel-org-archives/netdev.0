From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Fri, 22 May 2015 10:18:03 +0200
Message-ID: <1432282683.3493.5.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
	 <1432279948.3493.2.camel@sipsolutions.net>
	 <20150522074126.GA2921@gondor.apana.org.au>
	 <1432280608.3493.4.camel@sipsolutions.net>
	 <20150522080539.GA3194@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50313 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756006AbbEVISH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 04:18:07 -0400
In-Reply-To: <20150522080539.GA3194@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-22 at 16:05 +0800, Herbert Xu wrote:
> On Fri, May 22, 2015 at 09:43:28AM +0200, Johannes Berg wrote:
> > 
> > Oops, sorry, of course - I was running in a VM :)
> 
> Thanks!
> 
> Does this patch on top help?

Yep, that fixes things.

johannes
