From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Changes to cpsw and davinci_emac for getting MAC
 address
Date: Fri, 30 Jan 2015 17:42:24 -0800 (PST)
Message-ID: <20150130.174224.949071529587687598.davem@davemloft.net>
References: <1422473586-18100-1-git-send-email-tony@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: tony@atomide.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbbAaBmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 20:42:25 -0500
In-Reply-To: <1422473586-18100-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Lindgren <tony@atomide.com>
Date: Wed, 28 Jan 2015 11:33:03 -0800

> Here are a few patches to add common code for cpsw and davinci_emac for
> getting the MAC address. Looks like we can also now add code to get the
> MAC address on 3517 but in a slightly different way.

Applied to net-next, thanks.
