From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tipc: Clean up configuration file
Date: Tue, 19 Jan 2010 14:24:06 -0800 (PST)
Message-ID: <20100119.142406.126920373.davem@davemloft.net>
References: <1263928205-31788-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33423
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754863Ab0ASWX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 17:23:57 -0500
In-Reply-To: <1263928205-31788-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 19 Jan 2010 14:10:05 -0500

> This patch addresses a number of minor (mostly cosmetic) issues relating
> to the configuration of TIPC, including the following:
> 
> - Corrects range limits for maximum number of ports per node
> - Adds missing range limits for size of log buffer
> - Removes configuration setting relating to unsupported slave node capability
> - Standardizes description and help text wording for configuration settings
> - Removes unneeded blank spaces
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied, thanks.
