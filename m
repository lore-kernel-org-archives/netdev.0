From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [kbuild-all] [PATCH net-next] networking: use skb_put_zero()
Date: Fri, 16 Jun 2017 10:40:11 +0200
Message-ID: <1497602411.2622.4.camel@sipsolutions.net>
References: <20170613122818.3523-1-johannes@sipsolutions.net>
         <201706140443.XOCAM01f%fengguang.wu@intel.com>
         <20170613.170701.590433468190988945.davem@davemloft.net>
         <20170616083056.GF14764@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, netdev@vger.kernel.org, kbuild-all@01.org
To: Ye Xiaolong <xiaolong.ye@intel.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58442 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752067AbdFPIkS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 04:40:18 -0400
In-Reply-To: <20170616083056.GF14764@yexl-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 16:30 +0800, Ye Xiaolong wrote:
> Hi, David
> 
> On 06/13, David Miller wrote:
> > 
> > These are bogus reports I think.
> > 
> > Johannes's changes depends upon the wireless GIT tree I pulled in
> > right before I applied his patch.
> 
> Did you applied the patch on top of master branch?

Yes, but after merging my git tree.

There was no way the bot could figure this out - it was a discussion
we'd had earlier, and when I sent the pull request I also sent out the
patch a few minutes later.

johannes
