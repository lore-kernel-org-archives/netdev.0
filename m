From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: remove cpsw_ale_stop from
 cpsw_ale_destroy
Date: Thu, 06 Nov 2014 14:58:33 -0500 (EST)
Message-ID: <20141106.145833.1137376153976669409.davem@davemloft.net>
References: <1415192611-22722-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaKFT6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:58:35 -0500
In-Reply-To: <1415192611-22722-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 5 Nov 2014 18:33:31 +0530

> when cpsw is build as modulea and simple insert and removal of module
> creates a deadlock, due to delete timer. the timer is created and destroyed
> in cpsw_ale_start and cpsw_ale_stop which are from device open and close.
 ...
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thank you.
