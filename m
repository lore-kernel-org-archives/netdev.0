From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6gre: add a rtnl link alias for ip6gretap
Date: Fri, 26 Sep 2014 17:16:17 -0400 (EDT)
Message-ID: <20140926.171617.1452999636273092330.davem@davemloft.net>
References: <1411549380-4337-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755908AbaIZVQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:16:19 -0400
In-Reply-To: <1411549380-4337-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 24 Sep 2014 11:03:00 +0200

> With this alias, we don't need to load manually the module before adding an
> ip6gretap interface with iproute2.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
