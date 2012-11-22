From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter fixes for net
Date: Thu, 22 Nov 2012 15:28:33 -0500 (EST)
Message-ID: <20121122.152833.1540147166158752143.davem@davemloft.net>
References: <1353575452-3127-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756211Ab2KVU2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 15:28:35 -0500
In-Reply-To: <1353575452-3127-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Thu, 22 Nov 2012 10:10:50 +0100

> The following patchset contains two Netfilter fixes:
> 
> * Fix buffer overflow in the name of the timeout policy object
>   in the cttimeout infrastructure, from Florian Westphal.
> 
> * Fix a bug in the hash set in case that IP ranges are
>   specified, from Jozsef Kadlecsik.

Pulled, thanks Pablo.
