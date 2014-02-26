From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: order MPLS ethertypes numerically
Date: Wed, 26 Feb 2014 15:14:59 -0500 (EST)
Message-ID: <20140226.151459.1472275444458394950.davem@davemloft.net>
References: <1393327045-7170-1-git-send-email-Neil.Jerram@metaswitch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au
To: Neil.Jerram@metaswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaBZUPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:15:03 -0500
In-Reply-To: <1393327045-7170-1-git-send-email-Neil.Jerram@metaswitch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Jerram <Neil.Jerram@metaswitch.com>
Date: Tue, 25 Feb 2014 11:17:25 +0000

> All ethertypes other than ETH_P_MPLS_UC, ETH_P_MPLS_MC and
> ETH_P_ATMMPOA were already ordered numerically.  This commit moves
> those three ETH_P_... values into correct numerical order too.
> 
> Signed-off-by: Neil Jerram <Neil.Jerram@metaswitch.com>

Applied, thanks.
