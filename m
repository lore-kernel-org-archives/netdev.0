From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tipc: fix two corner issues
Date: Sun, 29 Mar 2015 12:41:02 -0700 (PDT)
Message-ID: <20150329.124102.537339857754574753.davem@davemloft.net>
References: <1427364624-5930-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbC2TcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:32:18 -0400
In-Reply-To: <1427364624-5930-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Thu, 26 Mar 2015 18:10:22 +0800

> The patch set aims at resolving the following two critical issues:
> 
> Patch #1: Resolve a deadlock which happens while all links are reset
> Patch #2: Correct a mistake usage of RCU lock which is used to protect
>           node list

Series applied, thanks.
