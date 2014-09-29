From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: remove unnecessary assignment.
Date: Mon, 29 Sep 2014 12:31:31 -0400 (EDT)
Message-ID: <20140929.123131.492779676543789426.davem@davemloft.net>
References: <1411974277-7236-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbaI2Qbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 12:31:33 -0400
In-Reply-To: <1411974277-7236-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 29 Sep 2014 15:04:37 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> This variable i is overwritten to 0 by following code
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thank you.
