From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bnx2x: correct LPI pass-through configuration
Date: Sun, 17 Jun 2012 16:17:15 -0700 (PDT)
Message-ID: <20120617.161715.313692202081735007.davem@davemloft.net>
References: <1339934690-28191-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	eilong@broadcom.com, yaniv.rosner@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2FQXRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:17:15 -0400
In-Reply-To: <1339934690-28191-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 17 Jun 2012 15:04:50 +0300

> Commit c8c60d88c59cbb48737732ba948663a3efe882aa contained
> an incorrect logic which enabled a buffer overflow when accessing 
> an array during LPI pass-through configuration.
> This patch fixes this issue by removing that logic altogether.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
