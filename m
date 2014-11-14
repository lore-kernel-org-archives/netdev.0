From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Fix build failure.
Date: Fri, 14 Nov 2014 01:24:56 -0500 (EST)
Message-ID: <20141114.012456.1212114487018969254.davem@davemloft.net>
References: <1415946090-1504-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbaKNGZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 01:25:01 -0500
In-Reply-To: <1415946090-1504-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 13 Nov 2014 22:21:30 -0800

> Add dependency on INET to fix following build error. I have also
> fixed MPLS dependency.
> 
> ERROR: "ip_route_output_flow" [net/openvswitch/openvswitch.ko]
> undefined!
> make[1]: *** [__modpost] Error 1
> 
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks Pravin.
