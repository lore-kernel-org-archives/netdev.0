From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/4] ipv6: add option to drop unsolicited neighbor
 advertisements
Date: Thu, 11 Feb 2016 04:28:10 -0500 (EST)
Message-ID: <20160211.042810.974143616679450202.davem@davemloft.net>
References: <1454589080-21354-1-git-send-email-johannes@sipsolutions.net>
	<1454589080-21354-4-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org, ja@ssi.bg,
	johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbcBKJ2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 04:28:13 -0500
In-Reply-To: <1454589080-21354-4-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu,  4 Feb 2016 13:31:20 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> In certain 802.11 wireless deployments, there will be NA proxies
> that use knowledge of the network to correctly answer requests.
> To prevent unsolicitd advertisements on the shared medium from
> being a problem, on such deployments wireless needs to drop them.
> 
> Enable this by providing an option called "drop_unsolicited_na".
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
