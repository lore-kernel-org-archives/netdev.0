From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Wed, 02 May 2007 04:01:04 -0400
Message-ID: <46384540.6090509@garzik.org>
References: <46383B00.4080605@garzik.org>	<20070502.002426.38687430.davem@davemloft.net>	<4638400D.5010306@garzik.org> <20070502.005412.99176640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56374 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbXEBIBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 04:01:08 -0400
In-Reply-To: <20070502.005412.99176640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Wed, 02 May 2007 03:38:53 -0400
> 
>> * adding code for a situation that never occurs in the upstream kernel.
> 
> What we could do is simply have Ingo carry this bnx2 driver patch in
> his -rt patch series, and then it will propagate into upstream as soon
> as it matters.

Seems quite reasonable to me...

	Jeff



