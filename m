From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/10] qed*: Bug fixes
Date: Mon, 20 Feb 2017 10:37:39 -0500 (EST)
Message-ID: <20170220.103739.96795933381020391.davem@davemloft.net>
References: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753252AbdBTPhl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:37:41 -0500
In-Reply-To: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 19 Feb 2017 15:26:13 +0200

> Hi Dave,
> 
> The 3 first patches here are a repost of
> ("qed: RoCE infrastructure fixes"). The fourth is an additional
> RoCE-related infrastructure fix, and the latter contain various fixes
> to qed/qede.
> 
> Notice patch #10 will create a conflict when net and net-next would
> be merged [although its fix is quite trivial].
> 
> Please consider applying these to `net'.

Linus made his release so all patches are going into net-next, which
this series doesn't apply cleanly to.  Please therefore respin your
series against net-next, thanks.
