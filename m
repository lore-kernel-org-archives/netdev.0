From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] ipv6: use addrconf_get_prefix_route() to
 remove peer addr
Date: Fri, 05 Sep 2014 17:13:52 -0700 (PDT)
Message-ID: <20140905.171352.1313756432028664257.davem@davemloft.net>
References: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
	<1409781562-4191-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaIFANx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:13:53 -0400
In-Reply-To: <1409781562-4191-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed,  3 Sep 2014 23:59:22 +0200

> addrconf_get_prefix_route() ensures to get the right route in the right table.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
