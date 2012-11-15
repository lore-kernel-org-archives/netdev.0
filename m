From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] tg3: Use tp->rxq_cnt when checking RSS
 tables.
Date: Wed, 14 Nov 2012 22:05:28 -0500 (EST)
Message-ID: <20121114.220528.1874954243909118983.davem@davemloft.net>
References: <1352940269-23821-2-git-send-email-mchan@broadcom.com>
	<1352940269-23821-3-git-send-email-mchan@broadcom.com>
	<1352940269-23821-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933282Ab2KODF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:05:29 -0500
In-Reply-To: <1352940269-23821-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 14 Nov 2012 16:44:29 -0800

> irq_cnt is no longer reliable since rxq_cnt can be independently configured.
> 
> Update version to 3.127.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
