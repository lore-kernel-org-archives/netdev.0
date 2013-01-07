From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ethtool: set addr_assign_type to NET_ADDR_SET
 when addr is passed on create
Date: Sun, 06 Jan 2013 21:05:36 -0800 (PST)
Message-ID: <20130106.210536.1888045395071192206.davem@davemloft.net>
References: <1357512117-5581-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	shemminger@vyatta.com, sassmann@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab3AGFFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:05:37 -0500
In-Reply-To: <1357512117-5581-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  6 Jan 2013 23:41:57 +0100

> In case user passed address via netlink during create, NET_ADDR_PERM was set.
> That is not correct so fix this by setting NET_ADDR_SET.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
