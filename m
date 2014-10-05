From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] if_link: add client name to port
 profile
Date: Sat, 04 Oct 2014 20:43:17 -0400 (EDT)
Message-ID: <20141004.204317.1135184102960286176.davem@davemloft.net>
References: <1412289683-8278-1-git-send-email-_govind@gmx.com>
	<1412289683-8278-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbaJEAnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:43:18 -0400
In-Reply-To: <1412289683-8278-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Fri,  3 Oct 2014 04:11:22 +0530

> This patch adds client name to port profile.
> 
> This is used by netlink client to send the client name in port profile.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

I really want to see what other developers think of this thing
because it seems extremely ad-hoc to me.
