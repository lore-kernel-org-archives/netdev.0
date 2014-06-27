From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] ipv6: Fix MLD Query message check
Date: Fri, 27 Jun 2014 00:22:10 -0700 (PDT)
Message-ID: <20140627.002210.105488116624455459.davem@davemloft.net>
References: <1403834273-5147-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbaF0HWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 03:22:11 -0400
In-Reply-To: <1403834273-5147-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Fri, 27 Jun 2014 09:57:53 +0800

> Based on RFC3810 6.2, we also need to check the hop limit and router alert
> option besides source address.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied, thanks.
