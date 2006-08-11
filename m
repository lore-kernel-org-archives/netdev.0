From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [NET 00/06]: Increase number of possible routing tables
Date: Fri, 11 Aug 2006 10:39:19 +0400
Message-ID: <44DC2617.7020200@tls.msk.ru>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:31312 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S932195AbWHKGj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 02:39:26 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> These are the updated patches (against net-2.6.19) to increase the number
> of possible routing tables to 2^32. They basically consist of four parts:
> 
> - Use u32 for routing table IDs everywhere inside the kernel

Just out of curiocity: why current limit of 2^31 isn't sufficient?
Or am I missing the point?

Thanks.

/mjt
