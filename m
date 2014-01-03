From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv4: fix tunneled VM traffic over hw VXLAN/GRE
 GSO NIC
Date: Fri, 03 Jan 2014 02:17:15 -0500 (EST)
Message-ID: <20140103.021715.1605676743011420529.davem@davemloft.net>
References: <1388092222-4549-1-git-send-email-weichunc@plumgrid.com>
	<20140102.190743.459474382050321416.davem@davemloft.net>
	<CAJZOPZJrSMsPoQXZ5if3Ak3vhVpPCz_=oO9eCcqk_KeopkWwKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weichunc@plumgrid.com, eric.dumazet@gmail.com, ast@plumgrid.com,
	netdev@vger.kernel.org, joseph.gasparakis@intel.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaACHRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 02:17:19 -0500
In-Reply-To: <CAJZOPZJrSMsPoQXZ5if3Ak3vhVpPCz_=oO9eCcqk_KeopkWwKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Fri, 3 Jan 2014 08:44:36 +0200

> Hi Dave, as I wrote you earlier, could you also add it to your -stable queue?

I already did.
