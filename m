From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: avoid disabling irq for netns id
Date: Wed, 30 Nov 2016 14:58:22 -0500 (EST)
Message-ID: <20161130.145822.727604546507312208.davem@davemloft.net>
References: <148045748887.22539.3188295553967836703.stgit@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
        xiyou.wangcong@gmail.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754371AbcK3T6w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:58:52 -0500
In-Reply-To: <148045748887.22539.3188295553967836703.stgit@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Tue, 29 Nov 2016 17:11:29 -0500

> From: Paul Moore <paul@paul-moore.com>
> 
> Bring back commit bc51dddf98c9 ("netns: avoid disabling irq for netns
> id") now that we've fixed some audit multicast issues that caused
> problems with original attempt.  Additional information, and history,
> can be found in the links below:
> 
>  * https://github.com/linux-audit/audit-kernel/issues/22
>  * https://github.com/linux-audit/audit-kernel/issues/23
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Paul Moore <paul@paul-moore.com>

This doesn't apply cleanly to the net-next tree, could you please
respin?

Thanks.
