From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnel: Fix off-by-one error in forming
 dev name.
Date: Fri, 29 Mar 2013 15:24:56 -0400 (EDT)
Message-ID: <20130329.152456.1494363037992917108.davem@davemloft.net>
References: <1364494906-9818-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756598Ab3C2TY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:24:58 -0400
In-Reply-To: <1364494906-9818-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 28 Mar 2013 11:21:46 -0700

> As Ben pointed out following patch fixes bug in checking device
> name length limits while forming tunnel device name.
> 
> CC: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
