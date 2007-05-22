From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix warnings with casting int to pointer
Date: Tue, 22 May 2007 16:13:17 -0700 (PDT)
Message-ID: <20070522.161317.75430275.davem@davemloft.net>
References: <20070522112703.GA12673@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44039
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756908AbXEVXNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:13:15 -0400
In-Reply-To: <20070522112703.GA12673@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 22 May 2007 21:27:03 +1000

> Hi Dave:
> 
> Here's patch to fix the warnings.
> 
> [IPSEC]: Fix warnings with casting int to pointer
> 
> This patch adds some casts to shut up the warnings introduced by my
> last patch that added a common interator function for xfrm algorightms.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Applied thanks Herbert.
