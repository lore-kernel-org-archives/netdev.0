From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DCCP]: Fix sock_orphan dead lock
Date: Fri, 05 May 2006 17:09:26 -0700 (PDT)
Message-ID: <20060505.170926.77245347.davem@davemloft.net>
References: <20060429131320.GA4145@gondor.apana.org.au>
	<20060503.233223.24747225.davem@davemloft.net>
	<20060504071750.GA17180@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, arjan@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23502
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751493AbWEFAJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 20:09:35 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060504071750.GA17180@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 4 May 2006 17:17:50 +1000

> Anyway, the same issue affects DCCP (and SCTP too probably).  Here
> is a patch that does the same thing for DCCP.

Thanks for catching that, applied.
