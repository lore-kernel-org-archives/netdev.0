From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] tipc: some small patches
Date: Fri, 18 Oct 2013 13:22:54 -0400 (EDT)
Message-ID: <20131018.132254.169905354661027944.davem@davemloft.net>
References: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756270Ab3JRRW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:22:58 -0400
In-Reply-To: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 18 Oct 2013 07:23:13 +0200

> Some small and relatively straightforward patches. With exception of
> the two first ones they are all unrelated and address minor issues.
> 
> v2: update of v1 (http://patchwork.ozlabs.org/patch/277404/)
> 
> -added commit to use memcpy_fromiovec on user data as per v1 feedback
> -updated sparse fix commit to drop chunks covered by above commit
> -added new commit that greatly simplifies the link lookup routine

Series applied, thanks Jon.
