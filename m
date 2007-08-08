From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH RFC]: napi_struct V6
Date: Wed, 08 Aug 2007 12:27:35 -0400
Message-ID: <46B9EEF7.7060009@garzik.org>
References: <20070807.215432.09951753.davem@davemloft.net> <20070808070628.284d805c@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47807 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763800AbXHHQ1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 12:27:52 -0400
In-Reply-To: <20070808070628.284d805c@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Someone please make sure Documentation/networking/netdevices.txt remains 
correct with regards to APIs and locking.

It -is- up to date, unlike NAPI howto.  It should not change very much 
due to this napi_struct work though, if at all.

	Jeff



