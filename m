From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix the check when handle RA
Date: Thu, 10 Jul 2014 16:56:54 -0700 (PDT)
Message-ID: <20140710.165654.637520801607248596.davem@davemloft.net>
References: <1404986566-9651-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com, greearb@candelatech.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaGJX4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 19:56:54 -0400
In-Reply-To: <1404986566-9651-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 10 Jul 2014 18:02:46 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> d9333196572(ipv6:  Allow accepting RA from local IP addresses.) made the wrong
> check, whether or not to accept RA with source-addr found on local machine, when
> accept_ra_from_local is 0.
> 
> Fixes: d9333196572(ipv6:  Allow accepting RA from local IP addresses.)
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
