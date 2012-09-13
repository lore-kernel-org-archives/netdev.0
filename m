From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] bnx2x: Link flap avoidance added
Date: Thu, 13 Sep 2012 15:01:51 -0400 (EDT)
Message-ID: <20120913.150151.733444078409320242.davem@davemloft.net>
References: <1347540981-16198-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783Ab2IMTBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 15:01:53 -0400
In-Reply-To: <1347540981-16198-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 13 Sep 2012 15:56:18 +0300

> In various flows in the bnx2x driver, the link is toggled unnecessarily -
> In such flows, if the link is already up it would be pulled down than
> raised up again, even if no change in the link was requested by the
> user.
> 
> This patch series tries to eliminate this problem, or at least to greatly
> reduce the number of cases that would actually cause such a scenario to
> happen.
> 
> Please consider applying this patch series to 'net-next'.

All applied, thanks.
