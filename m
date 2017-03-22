From: David Miller <davem@davemloft.net>
Subject: Re: [net-next sample action optimization v4 0/4]
Date: Wed, 22 Mar 2017 11:28:51 -0700 (PDT)
Message-ID: <20170322.112851.1917100598047204156.davem@davemloft.net>
References: <1490052750-60187-1-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@ovn.org, pshelar@ovn.org
To: azhou@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965446AbdCVS2x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:28:53 -0400
In-Reply-To: <1490052750-60187-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@ovn.org>
Date: Mon, 20 Mar 2017 16:32:26 -0700

> The sample action can be used for translating Openflow 'clone' action.
> However its implementation has not been sufficiently optimized for this
> use case. This series attempts to close the gap.
> 
> Patch 3 commit message has more details on the specific optimizations
> implemented.

Series applied, thanks.
