From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: use MDBA_SET_ENTRY_MAX for maxtype in
 nlmsg_parse()
Date: Thu, 15 Jan 2015 19:37:45 -0500 (EST)
Message-ID: <20150115.193745.1987573698001497201.davem@davemloft.net>
References: <1421335752-25204-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714AbbAPAhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 19:37:47 -0500
In-Reply-To: <1421335752-25204-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 15 Jan 2015 16:29:12 +0100

> This is just a cleanup, because in the current code MDBA_SET_ENTRY_MAX ==
> MDBA_SET_ENTRY.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
