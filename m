From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2 V3] Xen network: split event channels
 support
Date: Thu, 23 May 2013 18:41:07 -0700 (PDT)
Message-ID: <20130523.184107.1626078235368904477.davem@davemloft.net>
References: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org, jbeulich@suse.com,
	ian.campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759471Ab3EXBlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 21:41:08 -0400
In-Reply-To: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Wed, 22 May 2013 17:34:44 +0100

> This series adds a new feature called split event channels.
> 
> In the original implementation, only one event channel is setup between
> frontend and backend. This is not ideal as TX notification interferes with RX
> notification. Using dedicated event channels for TX and RX solves this issue.

Series applied, thanks.
