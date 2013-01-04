From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] netpoll: prepare for ipv6
Date: Thu, 03 Jan 2013 18:56:18 -0800 (PST)
Message-ID: <20130103.185618.1472655606309483969.davem@davemloft.net>
References: <1357267541-6433-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab3ADC4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 21:56:19 -0500
In-Reply-To: <1357267541-6433-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri,  4 Jan 2013 10:45:39 +0800

> v3: fix CONFIG_IPV6=m case

You're talking about a change that isn't even present in this patch.

That's why people do "[PATCH 0/N]" cover postings with their
patch series, to collect information like this in the most
useful and relevent place.

Then I can check your patch set into a branch, and then do
a merge into my master branch and make the merge commit have
your cover letter as the commit message.

I'm not applying this series, submit it properly.

Thanks.
