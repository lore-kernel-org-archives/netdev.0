From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: unnecessary to check if vlan_pcpu_stats is NULL
Date: Tue, 22 Apr 2014 21:29:11 -0400 (EDT)
Message-ID: <20140422.212911.2165311509701645417.davem@davemloft.net>
References: <1398080948-31851-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbaDWB3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 21:29:13 -0400
In-Reply-To: <1398080948-31851-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 21 Apr 2014 19:49:08 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> if allocating memory for vlan_pcpu_stats failed, the device can not be operated
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
