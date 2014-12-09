From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: drop tx side permission checks
Date: Tue, 09 Dec 2014 13:30:35 -0500 (EST)
Message-ID: <20141209.133035.679050429504559837.davem@davemloft.net>
References: <1417614284-24125-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ying.xue@windriver.com,
	jon.maloy@ericsson.com, richard.alpe@ericsson.com,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaLISah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:30:37 -0500
In-Reply-To: <1417614284-24125-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 3 Dec 2014 14:44:44 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Part of the old remote management feature is a piece of code
> that checked permissions on the local system to see if a certain
> operation was permitted, and if so pass the command to a remote
> node. This serves no purpose after the removal of remote management
> with commit 5902385a2440 ("tipc: obsolete the remote management
> feature") so we remove it.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.
