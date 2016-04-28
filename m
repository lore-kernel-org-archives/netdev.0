From: David Miller <davem@davemloft.net>
Subject: Re: pull request [net]: batman-adv-0160426
Date: Thu, 28 Apr 2016 16:43:51 -0400 (EDT)
Message-ID: <20160428.164351.907536352207317310.davem@davemloft.net>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: a@unstable.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbcD1Uny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:43:54 -0400
In-Reply-To: <1461641239-7097-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <a@unstable.cc>
Date: Tue, 26 Apr 2016 11:27:14 +0800

> In this patchset you can find the following fixes:

Pulled, even though there were some typos in the commit messages.

> Patch 2 and 3 have no "Fixes:" tag because the offending commits date
> back to when batman-adv was not yet officially in the net tree.

This is not correct.  Instead, in the future, you should provide a
Fixes: tag that indicates the commit that merged batman-adv into the
upstream tree initially.

Thanks.
