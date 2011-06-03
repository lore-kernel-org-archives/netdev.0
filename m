From: David Miller <davem@davemloft.net>
Subject: Re: Are we allowed to add a new column to /proc/net/tcp?
Date: Fri, 03 Jun 2011 16:25:15 -0700 (PDT)
Message-ID: <20110603.162515.1467553057621620995.davem@davemloft.net>
References: <4DE9615E.1010309@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab1FCXZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 19:25:18 -0400
In-Reply-To: <4DE9615E.1010309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 03 Jun 2011 15:34:06 -0700

> If there is another way to get at this information for
> arbritrary TCP sockets, I'm interested in that as well.

"ss" can dump everything, even the full contents of tcp_info
