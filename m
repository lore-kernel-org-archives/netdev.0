From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xdp: don't export dev_change_xdp_fd()
Date: Wed, 12 Apr 2017 10:43:05 -0400 (EDT)
Message-ID: <20170412.104305.1172870149660350365.davem@davemloft.net>
References: <20170412073207.27029-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com,
        johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753881AbdDLOnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:43:10 -0400
In-Reply-To: <20170412073207.27029-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 12 Apr 2017 09:32:07 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Since dev_change_xdp_fd() is only used in rtnetlink, which must
> be built-in, there's no reason to export dev_change_xdp_fd().
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks Johannes.
