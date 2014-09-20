From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/29] Add support for the Intel FM10000
 Ethernet Switch Host Interface
Date: Fri, 19 Sep 2014 22:03:32 -0400 (EDT)
Message-ID: <20140919.220332.1854299635044838363.davem@davemloft.net>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
	<541CC1C0.9090204@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, nhorman@redhat.com,
	netdev@vger.kernel.org, john.fastabend@gmail.com,
	matthew.vick@intel.com, jeffrey.t.kirsher@intel.com,
	sassmann@redhat.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053AbaITCDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 22:03:34 -0400
In-Reply-To: <541CC1C0.9090204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 19 Sep 2014 16:52:32 -0700

> I was wondering what changes you wanted for these patches?  The only
> feedback that I have gotten so far was on the last 2 patches, and a one
> liner about dev_consume_skb_any vs dev_kfree_skb_any.  Is there
> something I missed, or do I need  to resubmit the entire set with some
> other sort of fix?

Any time there is any change requested or intended adjustment, I mark
the entire series as changes requested, and you are expected to make
the adjustments and resubmit the entire series.

I do this silently to work my queue as efficiently as possible, and yet
I still sometimes fall very far behind and get backlogged.

Please do not ask me to repeat what's already been stated in the patch
followup postings as I'll fall even further behind.

Thanks.
