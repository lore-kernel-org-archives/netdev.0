From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] xen-netback: remove skb in xen_netbk_alloc_page
Date: Mon, 25 Mar 2013 12:20:34 -0400 (EDT)
Message-ID: <20130325.122034.1355974655254289883.davem@davemloft.net>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	<1364209702-12437-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com, david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202Ab3CYQUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:20:39 -0400
In-Reply-To: <1364209702-12437-5-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 25 Mar 2013 11:08:20 +0000

> This variable is never used.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
