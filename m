From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv4 : igmp : fix error handle in ip_mc_add_src()
Date: Wed, 23 Nov 2011 17:32:12 -0500 (EST)
Message-ID: <20111123.173212.1247350681218413175.davem@davemloft.net>
References: <1322018343-7552-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab1KWWcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 17:32:17 -0500
In-Reply-To: <1322018343-7552-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Wed, 23 Nov 2011 11:19:03 +0800

> from: Jun Zhao <mypopydev@gmail.com>
> 
> When add sources to interface failure, need to roll back the sfcount[MODE]
> to before state. We need to match it corresponding.
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>

Applied, thanks.
