From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Tue, 21 Oct 2008 16:43:42 -0700 (PDT)
Message-ID: <20081021.164342.135191750.davem@davemloft.net>
References: <20081017130333.GA8297@ff.dom.local>
	<48F89D33.9090809@trash.net>
	<20081017204543.GB2527@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41195
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752021AbYJUXoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 19:44:06 -0400
In-Reply-To: <20081017204543.GB2527@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 17 Oct 2008 22:45:43 +0200

> BTW, I'm not sure if I'm expected to redo any patches in this thread.
> (Probably some things like this teql_peek() could be removed with
> ->requeue() killing.)

In any event, you should resubmit these when I open the net-next-2.6
tree up in about a week or so.

It looks like Patrick is in agreement about these changes and they
look mostly fine to me too, FWIW.

Thanks.
