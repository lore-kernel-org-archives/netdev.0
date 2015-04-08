From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] hv_netvsc: linearize SKBs bigger than
 MAX_PAGE_BUFFER_COUNT-2 pages
Date: Wed, 08 Apr 2015 12:28:10 -0400 (EDT)
Message-ID: <20150408.122810.2304841162873681785.davem@davemloft.net>
References: <1428508446-18423-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
	devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	jasowang@redhat.com
To: vkuznets@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754418AbbDHQ2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:28:13 -0400
In-Reply-To: <1428508446-18423-1-git-send-email-vkuznets@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Wed,  8 Apr 2015 17:54:04 +0200

> This patch series fixes the same issue which was fixed in Xen with commit
> 97a6d1bb2b658ac85ed88205ccd1ab809899884d ("xen-netfront: Fix handling packets on
> compound pages with skb_linearize").

This patch series only applies on net-next, so that's where I put it.

Please be completely explicit about this in the future, rather than
forcing me to try and figure it out.

Thanks.
