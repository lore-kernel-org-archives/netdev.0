From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] enic: do notify_check before returning credits
Date: Fri, 27 Feb 2015 15:58:57 -0500 (EST)
Message-ID: <20150227.155857.1596697732937088305.davem@davemloft.net>
References: <1424858215-18918-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, ssujith@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932274AbbB0U67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:58:59 -0500
In-Reply-To: <1424858215-18918-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 25 Feb 2015 15:26:55 +0530

> From: Sujith Sankar <ssujith@cisco.com>
> 
> We should complete notify_check before returning the credits. Once we return the
> credits, adaptor may access the notify data.
> 
> Signed-off-by: Sujith Sankar <ssujith@cisco.com>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
