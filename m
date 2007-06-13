From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/7] sky2 version 1.15 (88e8071) support
Date: Wed, 13 Jun 2007 16:05:23 -0400
Message-ID: <46704E03.8060307@garzik.org>
References: <20070605002320.868185090@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39202 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979AbXFMUF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:05:26 -0400
In-Reply-To: <20070605002320.868185090@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> These changes are to enable the Yukon Extreme (88e8071)
> chipset. This chip is similar to earlier chip but has a different
> set of offloading operations and some other minor quirks.
> 
> Marvell has given me some evaluation boards with the 88e8071
> chip set. The chip is available now, but haven't seen a systems
> with the hardware yet. The support fot this is exprerimental
> at this point, but haven't encountered any new problems.

Just to confirm... these are all for #upstream (2.6.23), correct?


