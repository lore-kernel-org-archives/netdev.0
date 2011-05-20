From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: stop Features changed message
Date: Fri, 20 May 2011 14:26:50 -0400 (EDT)
Message-ID: <20110520.142650.1065397635610543796.davem@davemloft.net>
References: <20110520090208.7709bec3@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934878Ab1ETS0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 14:26:52 -0400
In-Reply-To: <20110520090208.7709bec3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 May 2011 09:02:08 -0700

> The new in 2.6.39 message "Features changed:" occurs a lot
> on many configurations. It provides information to driver developers
> but is not user friendly. Printing out hex values is just confusing.
> Reduce priority so that it doesn't show up unless debugging.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

THis was already in net-2.6 and is queued up for 2.6.39-stable
