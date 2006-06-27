From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH REPOST 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 09:31:57 -0500
Message-ID: <1151418717.3207.21.camel@stevo-desktop>
References: <E1FvD1V-00043F-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:43072 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1161062AbWF0Ob7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 10:31:59 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FvD1V-00043F-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'd like to know more about what the RDMA device is going to do with this
> information.  I thought RDMA was for receiving packets? Most of the info
> here pertains to transmission.
> 

RDMA Ethernet devices adhere to a set of protocols defined by the IETF.
See the RDDP WG (http://www.ietf.org/html.charters/rddp-charter.html)
for the Internet Drafts that define the protocols.

Steve.

