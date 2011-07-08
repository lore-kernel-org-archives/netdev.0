From: David Miller <davem@davemloft.net>
Subject: Re: network related lockdep splat in 3.0-rc6+
Date: Fri, 08 Jul 2011 15:48:52 -0700 (PDT)
Message-ID: <20110708.154852.412390879048717424.davem@davemloft.net>
References: <4E1786D9.3020209@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab1GHWs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 18:48:56 -0400
In-Reply-To: <4E1786D9.3020209@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 08 Jul 2011 15:38:17 -0700

> This has some additional NFS patches as well, but is otherwise
> un-tainted.
> 

"networking related" when it's honking in the scheduler
wakeup paths?
