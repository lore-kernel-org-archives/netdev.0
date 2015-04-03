From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] Revert "netns: don't clear nsid too early on
 removal"
Date: Fri, 03 Apr 2015 12:36:45 -0400 (EDT)
Message-ID: <20150403.123645.263185113768374979.davem@davemloft.net>
References: <551E63B9.9050208@6wind.com>
	<1428055357-15289-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbbDCQgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 12:36:47 -0400
In-Reply-To: <1428055357-15289-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  3 Apr 2015 12:02:36 +0200

> This reverts
> commit 4217291e592d ("netns: don't clear nsid too early on removal").
> 
> This is not the right fix, it introduces races.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
