From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 0/6 RESEND] Add qdisc->ops->peek() support.
Date: Thu, 30 Oct 2008 13:25:06 +0000
Message-ID: <20081030132506.GH22853@ff.dom.local>
References: <20081030130518.GA22853@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:20204 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241AbYJ3NZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 09:25:13 -0400
Received: by ey-out-2122.google.com with SMTP id 6so215926eyi.37
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 06:25:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081030130518.GA22853@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 01:05:18PM +0000, Jarek Poplawski wrote:
...
> PATCH 6/6 adds my simple idea not to prevent even nonsense configs.
> It is optional.

Actually, after a below mentioned change in patch 3/6 this patch isn't
optional anymore.

> This resend is redone against current net-next with slightly changed
> patches 3/6 (check added in register_qdisc()) and 4/6 (teql_peek()
> made nonfunctional), according to Patric's suggestions, I hope.

Sorry for misspelling.

Jarek P.
