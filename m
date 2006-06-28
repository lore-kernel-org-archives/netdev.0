From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: TOE, etc.
Date: Wed, 28 Jun 2006 13:56:32 -0500
Message-ID: <1151520992.13399.15.camel@stevo-desktop>
References: <20060627.214323.92582051.davem@davemloft.net>
	 <20060628053554.GA5928@gondor.apana.org.au>
	 <1151506497.14895.51.camel@stevo-desktop>
	 <20060628.113646.85408870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:8002 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1750998AbWF1S4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 14:56:34 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060628.113646.85408870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 11:36 -0700, David Miller wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Wed, 28 Jun 2006 09:54:57 -0500
> 
> > Doesn't iSCSI have this same issue?
> 
> Software iSCSI implementations don't have the issue because
> they go through the stack using normal sockets and normal
> device send and receive.
> -

Right.  I was assuming, in this thread we were talking about iSCSI
devices where the TCP stack is in HW/FW on the adapter...

Steve.


