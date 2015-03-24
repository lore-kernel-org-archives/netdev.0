From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] Netfilter updates for net-next
Date: Mon, 23 Mar 2015 22:03:06 -0400 (EDT)
Message-ID: <20150323.220306.1069658156024146687.davem@davemloft.net>
References: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbbCXCDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 22:03:07 -0400
In-Reply-To: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 23 Mar 2015 12:36:16 +0100

> The following patchset contains Netfilter updates for net-next.
> Basically, more incremental updates for br_netfilter from Florian
> Westphal, small nf_tables updates (including one fix for rb-tree
> locking) and small two-liner to add extra validation for the REJECT6
> target.
> 
> More specifically, they are:
...
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks a lot Pablo.
