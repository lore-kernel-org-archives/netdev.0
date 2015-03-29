From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] virtio: simplify the using of received in
 virtnet_poll
Date: Sun, 29 Mar 2015 12:39:10 -0700 (PDT)
Message-ID: <20150329.123910.1354369600259208303.davem@davemloft.net>
References: <1427355585-10365-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbbC2Ta0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:30:26 -0400
In-Reply-To: <1427355585-10365-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 26 Mar 2015 15:39:45 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> received is 0, no need to minus it and use "+=" to reassign it
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
