From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fix netlink max attr size
Date: Thu, 20 Aug 2015 14:38:48 -0700 (PDT)
Message-ID: <20150820.143848.1696871373419083174.davem@davemloft.net>
References: <1440008975-41080-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbHTVit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:38:49 -0400
In-Reply-To: <1440008975-41080-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 19 Aug 2015 11:29:35 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> .maxtype should match .policy.  Probably just been getting lucky here
> because IFLA_BRPORT_MAX > IFLA_BR_MAX.
> 
> Fixes: 13323516 ("bridge: implement rtnl_link_ops->changelink")
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied.
