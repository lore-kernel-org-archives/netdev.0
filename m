From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-next] nf_defrag_ipv6: fix oops on module unloading
Date: Thu, 27 Sep 2012 18:18:25 -0400 (EDT)
Message-ID: <20120927.181825.2284387959562808924.davem@davemloft.net>
References: <20120925160750.30475.77562.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: khlebnikov@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287Ab2I0WS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:18:26 -0400
In-Reply-To: <20120925160750.30475.77562.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 25 Sep 2012 20:07:50 +0400

> fix copy-paste error introduced in linux-next commit
> "ipv6: add a new namespace for nf_conntrack_reasm"
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Applied to net-next, thanks.
