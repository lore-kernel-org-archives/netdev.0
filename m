From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net] Open vSwitch
Date: Sun, 16 Nov 2014 15:02:11 -0500 (EST)
Message-ID: <20141116.150211.1398831881975864743.davem@davemloft.net>
References: <1416015444-1519-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaKPUCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 15:02:13 -0500
In-Reply-To: <1416015444-1519-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri, 14 Nov 2014 17:37:24 -0800

> Following fixes are accumulated in ovs-repo.
> Three of them are related to protocol processing, one is
> related to memory leak in case of error and one is to
> fix race.
> Patch "Validate IPv6 flow key and mask values" has conflicts
> with net-next, Let me know if you want me to send the patch
> for net-next.

Pulled, thanks a lot.

I'll sort out the merge conflicts next time I merge net into
net-next, thanks for offering.
