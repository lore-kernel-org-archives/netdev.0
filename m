From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6 RESEND] Add qdisc->ops->peek() support.
Date: Fri, 31 Oct 2008 00:47:19 -0700 (PDT)
Message-ID: <20081031.004719.33191743.davem@davemloft.net>
References: <20081030130518.GA22853@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751865AbYJaHro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:47:44 -0400
In-Reply-To: <20081030130518.GA22853@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 30 Oct 2008 13:05:18 +0000

> So here is a re-try.
> 
> PATCH 6/6 adds my simple idea not to prevent even nonsense configs.
> It is optional.
> 
> This resend is redone against current net-next with slightly changed
> patches 3/6 (check added in register_qdisc()) and 4/6 (teql_peek()
> made nonfunctional), according to Patric's suggestions, I hope.

All applied, thanks a lot Jarek.
