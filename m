From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/6] dccp: several long-tested updates
 from dccp test tree
Date: Mon, 04 Jul 2011 17:55:44 -0700 (PDT)
Message-ID: <20110704.175544.2071886036329199005.davem@davemloft.net>
References: <test_tree_patch_set_update_2011-07-04>
	<1309806079-21604-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab1GEA4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 20:56:49 -0400
In-Reply-To: <1309806079-21604-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon,  4 Jul 2011 13:01:13 -0600

> This set contains several minor fixes and CWV for CCID-2.
> 
>   Patch #1: fixes several issues in slow-path input processing.
>   Patch #2: refactors common pattern (queueing + cloning) into the same function.
>   Patch #3: straightens cosmetics of info message appearing in logs.
>   Patch #4: puts frequently used CCID-2 inline function into header file. 
>   Patch #5: reuses existing function to test for data packets in CCID-2.
>   Patch #6: implements congestion window validation (RFC 2861) in CCID-2.
> 
> This set is also available for today's net-next-2.6 at
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next-2.6   ===>   subtree "dccp"

Pulled, thanks Gerrit.
