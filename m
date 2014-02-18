From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] rtnl: make ifla_policy static
Date: Tue, 18 Feb 2014 18:16:12 -0500 (EST)
Message-ID: <20140218.181612.1865017891209094642.davem@davemloft.net>
References: <1392753198-9437-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, xiyou.wangcong@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com, jbenc@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795AbaBRXQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 18:16:15 -0500
In-Reply-To: <1392753198-9437-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 18 Feb 2014 20:53:18 +0100

> The only place this is used outside rtnetlink.c is veth. So provide
> wrapper function for this usage.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
