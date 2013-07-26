From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 net-next] bond: cleanup netpoll code
Date: Fri, 26 Jul 2013 15:25:27 -0700 (PDT)
Message-ID: <20130726.152527.751275888873586427.davem@davemloft.net>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
	<20130724115357.4d4bddcb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, jiri@resnulli.us, fubar@us.ibm.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759599Ab3GZWZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 18:25:28 -0400
In-Reply-To: <20130724115357.4d4bddcb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 24 Jul 2013 11:53:57 -0700

> This started out with fixing a sparse warning, then I realized that
> the wrapper function bond_netpoll_info could just be removed
> by rolling it into the enable code.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
