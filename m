From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] drivers: net: xen-netfront: remove residual dead
 code
Date: Mon, 12 Jan 2015 16:44:52 -0500 (EST)
Message-ID: <20150112.164452.45501307901130900.davem@davemloft.net>
References: <1420881625-4935-1-git-send-email-v.maffione@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	david.vrabel@citrix.com, boris.ostrovsky@oracle.com,
	konrad.wilk@oracle.com
To: v.maffione@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbbALVoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:44:54 -0500
In-Reply-To: <1420881625-4935-1-git-send-email-v.maffione@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincenzo Maffione <v.maffione@gmail.com>
Date: Sat, 10 Jan 2015 10:20:25 +0100

> This patch removes some unused arrays from the netfront private
> data structures. These arrays were used in "flip" receive mode.
> 
> Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>

Applied to net-next.
