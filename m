From: Ye Xiaolong <xiaolong.ye@intel.com>
Subject: Re: [kbuild-all] [PATCH net-next] networking: use skb_put_zero()
Date: Fri, 16 Jun 2017 16:30:56 +0800
Message-ID: <20170616083056.GF14764@yexl-desktop>
References: <20170613122818.3523-1-johannes@sipsolutions.net>
 <201706140443.XOCAM01f%fengguang.wu@intel.com>
 <20170613.170701.590433468190988945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkp@intel.com, netdev@vger.kernel.org, johannes@sipsolutions.net,
        kbuild-all@01.org, johannes.berg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:44567 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752712AbdFPIbF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 04:31:05 -0400
Content-Disposition: inline
In-Reply-To: <20170613.170701.590433468190988945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David

On 06/13, David Miller wrote:
>
>These are bogus reports I think.
>
>Johannes's changes depends upon the wireless GIT tree I pulled in
>right before I applied his patch.

Did you applied the patch on top of master branch?

Thanks,
Xiaolong

>_______________________________________________
>kbuild-all mailing list
>kbuild-all@lists.01.org
>https://lists.01.org/mailman/listinfo/kbuild-all
