From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Configuring the same IP on multiple addresses
Date: Tue, 30 Oct 2007 09:47:12 -0400
Message-ID: <472735E0.9050208@hp.com>
References: <47262079.90507@hp.com>	<20071029.152559.174870963.davem@davemloft.net> <20071029.154258.39630263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:34977 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948AbXJ3Nr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 09:47:29 -0400
In-Reply-To: <20071029.154258.39630263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 29 Oct 2007 15:25:59 -0700 (PDT)
> 
>> Can you guys please just state upfront what virtualization
>> issue is made more difficult by features you want to remove?
> 
> Sorry, I mentioned "virtualization" because that's been the
> largest majority of the cases being presented lately.

Nope, not virtualization.

> 
> I suspect in your case it's some multicast or SCTP thing :-)
> 

Neither of these really either, although I should try to see how
SCTP behaves in this configuration.

As Brian said, a customer asked us a question, and we didn't know the
history.  No one is trying to remove functionality or features.
We'd just like to know the why, and the answer of "why not" doesn't
fly very well.

Although in the IPv6 case, there might be issues.

-vlad

