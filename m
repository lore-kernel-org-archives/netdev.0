From: Jeff Garzik <jeff@garzik.org>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 00:10:40 -0400
Message-ID: <46EDFE40.5060306@garzik.org>
References: <20070916.202258.03371690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58176 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbXIQEKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 00:10:44 -0400
In-Reply-To: <20070916.202258.03371690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> We've touched so much in net-2.6.24 that we really should be auditing
> the thing and fixing any bugs that have been added.  If you're bored
> and looking for something to do, pick an odd NAPI driver and audit it
> in the net-2.6.24 tree.

You could try that weird "post patches on the list" thing for review.

I dunno about sparc64, but IMO any networking work you do yourself and 
commit yourself should also be sent to the list for review.

	Jeff


