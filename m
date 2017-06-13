From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] networking: use skb_put_zero()
Date: Tue, 13 Jun 2017 17:07:01 -0400 (EDT)
Message-ID: <20170613.170701.590433468190988945.davem@davemloft.net>
References: <20170613122818.3523-1-johannes@sipsolutions.net>
        <201706140443.XOCAM01f%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, kbuild-all@01.org,
        netdev@vger.kernel.org, johannes.berg@intel.com
To: lkp@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdFMVHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:07:05 -0400
In-Reply-To: <201706140443.XOCAM01f%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These are bogus reports I think.

Johannes's changes depends upon the wireless GIT tree I pulled in
right before I applied his patch.
