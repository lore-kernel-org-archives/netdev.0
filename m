From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 22:19:11 -0400
Message-ID: <1270088351.26743.121.camel@bigi>
References: <20100331135505.GC14082@gondor.apana.org.au>
	 <1270044768.26743.58.camel@bigi>
	 <20100331141525.GA14331@gondor.apana.org.au>
	 <20100331.135735.00480230.davem@davemloft.net>
	 <20100401002244.GA18893@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:32596 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463Ab0DACTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 22:19:16 -0400
Received: by qw-out-2122.google.com with SMTP id 8so251966qwh.37
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 19:19:14 -0700 (PDT)
In-Reply-To: <20100401002244.GA18893@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 08:22 +0800, Herbert Xu wrote:

> OK, in that case please change xfrm_state_flush too.  Right now
> it also notifies on empty.

It shouldnt. I will double check it tomorrow..

cheers,
jamal

