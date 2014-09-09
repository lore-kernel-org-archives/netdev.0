From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: bind ip_nonlocal_bind to current netns
Date: Tue, 09 Sep 2014 11:27:24 -0700 (PDT)
Message-ID: <20140909.112724.1513813263306169050.davem@davemloft.net>
References: <1409922543-708-1-git-send-email-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, vyasevich@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbaIIS1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:27:25 -0400
In-Reply-To: <1409922543-708-1-git-send-email-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <vincent@bernat.im>
Date: Fri,  5 Sep 2014 15:09:03 +0200

> net.ipv4.ip_nonlocal_bind sysctl was global to all network
> namespaces. This patch allows to set a different value for each
> network namespace.
> 
> Signed-off-by: Vincent Bernat <vincent@bernat.im>

Applied to net-next, thanks.
