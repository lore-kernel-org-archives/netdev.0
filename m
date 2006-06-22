From: David Miller <davem@davemloft.net>
Subject: Re: [0/5] GSO: Generic Segmentation Offload
Date: Thu, 22 Jun 2006 03:08:50 -0700 (PDT)
Message-ID: <20060622.030850.105431151.davem@davemloft.net>
References: <20060622081211.GA22505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1684
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161035AbWFVKIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 06:08:50 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060622081211.GA22505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Jun 2006 18:12:11 +1000

> This is a repost of the GSO patches.  The main change is the fix to a bug
> in the way dev->gso_skb is freed.  This series requires the dev_deactivate
> patch that I just posted.

Applied, thanks a lot Herbert.
