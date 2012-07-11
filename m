From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix endian
Date: Wed, 11 Jul 2012 01:32:01 -0700 (PDT)
Message-ID: <20120711.013201.1539028091232646517.davem@davemloft.net>
References: <1341914172-22075-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854Ab2GKIcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:32:03 -0400
In-Reply-To: <1341914172-22075-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 10 Jul 2012 17:56:12 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> mld->mld_maxdelay is net endian, so we should use ntohs, not htons
> 
> CC: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
