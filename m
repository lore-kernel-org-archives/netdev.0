From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] TIPC: Removing EXPERIMENTAL label
Date: Mon, 21 May 2012 02:39:26 -0400 (EDT)
Message-ID: <20120521.023926.548567931208958037.davem@davemloft.net>
References: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	ying.xue@windriver.com, erik.hugne@ericsson.com,
	allan.stephens@windriver.com, maloy@donjonn.com
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab2EUGjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 02:39:39 -0400
In-Reply-To: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 21 May 2012 01:59:12 -0400

> With the latest series of patches from Paul Gortmaker and Allan
> Stephens TIPC is now functionally mature and stable enough to
> justify removal of the EXPERIMENTAL label.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

I'll let Paul Gortmaker decide whether this is warranted or
not.

I don't really want to all of a sudden start seeing patches from
people like you and the windriver folks, who effectively wrote off
upstream and left poor Paul Gortmaker holding the bag and having to
take care of EVERYTHING.

You can't just do nothing for years, end up making someone else
do it, then say "Hey here I am, I feel like submitting upstream
patches now" after I've spent this entire time starting to trust
Paul for TIPC patches.
