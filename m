From: David Miller <davem@davemloft.net>
Subject: Re: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 14:19:48 -0700 (PDT)
Message-ID: <20060630.141948.66059424.davem@davemloft.net>
References: <20060630054209.GA28558@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52936
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932809AbWF3VTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:19:49 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060630054209.GA28558@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jun 2006 15:42:09 +1000

> I've added GSO for TCPv6 and updated Ananda's patch.  Please note that
> the following patches have only been compile-tested.

I applied this and pushed it to Linus, let's cross our fingers :)
