From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 16:58:02 -0400
Message-ID: <48A34ADA.4020707@myri.com>
References: <48A23137.2010107@myri.com>	<20080812.181549.229367205.davem@davemloft.net>	<48A30834.4090802@myri.com> <20080813.132750.16161628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@robur.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1804 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751286AbYHMVFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 17:05:39 -0400
In-Reply-To: <20080813.132750.16161628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> 
> Thanks for testing and providing those profiles.
> 
> I'll get this fix to Linus soon.

No problem.  Thanks for the excellent multi-queue tx work.

FWIW, I tripped over this when testing a myri10ge patch
for multi-queue tx...

Drew
