From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: rename shadowed variable
Date: Mon, 18 Nov 2013 15:34:21 -0500 (EST)
Message-ID: <20131118.153421.336023733508575509.davem@davemloft.net>
References: <1384804498-7482-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab3KRUeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 15:34:23 -0500
In-Reply-To: <1384804498-7482-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 18 Nov 2013 20:54:58 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Sparse pointed out that the new flags variable I had added
> shadowed an existing one, rename the new one to avoid that,
> making the code clearer.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks Johannes.
