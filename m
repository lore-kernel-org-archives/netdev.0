From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND][PATCH 2.6.28] myri10ge: Add multiqueue TX support
Date: Thu, 25 Sep 2008 15:07:44 -0400
Message-ID: <48DBE180.9090508@garzik.org>
References: <48DB1056.5040206@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51027 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030AbYIYTHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 15:07:48 -0400
In-Reply-To: <48DB1056.5040206@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Add multiqueue TX support to myri10ge.
>     
> Signed-off-by: Brice Goglin <brice@myri.com>

Did not apply to net-next successfully...  I dropped the two patches you 
submitted, as discussed in the thread where DaveM replied.  Maybe that 
drop is tripping us up?

Let's resync based on DaveM's current net-next, ok?

	Jeff




