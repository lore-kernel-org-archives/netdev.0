From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6gre: Allow live link address change
Date: Wed, 08 Jun 2016 22:35:59 -0700 (PDT)
Message-ID: <20160608.223559.777883253566604510.davem@davemloft.net>
References: <1465413343-1405-1-git-send-email-schoudah@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: schoudah@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161701AbcFIFgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 01:36:03 -0400
In-Reply-To: <1465413343-1405-1-git-send-email-schoudah@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shweta Choudaha <schoudah@brocade.com>
Date: Wed, 8 Jun 2016 20:15:43 +0100

> The ip6 GRE tap device should not be forced to down state to change
> the mac address and should allow live address change for tap device
> similar to ipv4 gre.
> 
> Signed-off-by: Shweta Choudaha <schoudah@brocade.com>

Applied to net-next, thanks.
