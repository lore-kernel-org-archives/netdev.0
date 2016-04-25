From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] netlink: align attributes when needed
 (patchset #2)
Date: Mon, 25 Apr 2016 15:09:33 -0400 (EDT)
Message-ID: <20160425.150933.1465492349349273571.davem@davemloft.net>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	stephen@networkplumber.org, pshelar@nicira.com, aar@pengutronix.de,
	linux-wpan@vger.kernel.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932699AbcDYTJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:09:40 -0400
In-Reply-To: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 25 Apr 2016 10:25:13 +0200

> This is the continuation (series #2) of the work done to align netlink
> attributes when these attributes contain some 64-bit fields.
> 
> In patch #3, I didn't modify the function ila_encap_nlsize(). I was waiting
> feedback for this patch: http://patchwork.ozlabs.org/patch/613766/
> If it's approved, there will be an update to switch nla_total_size() to
> nla_total_size_64bit() after the merge of net in net-next.

Looks good, series applied, thanks!
