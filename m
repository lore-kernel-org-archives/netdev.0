From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge
Date: Tue, 20 Jun 2006 14:42:41 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0606201441490.5498@g5.osdl.org>
References: <20060620070450.GA12609@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54971 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751205AbWFTVnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 17:43:23 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060620070450.GA12609@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 20 Jun 2006, Herbert Xu wrote:
> 
> [FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge

Btw, please don't use attachments in vain. Now I can't see it by default, 
I can reply and quote it etc etc.

		Linus
