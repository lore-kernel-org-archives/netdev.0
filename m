From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Fix the MSI flags
Date: Thu, 26 Jun 2014 17:37:41 -0700 (PDT)
Message-ID: <20140626.173741.1948940293365707195.davem@davemloft.net>
References: <1403670176-12072-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariel.elior@qlogic.com
To: wangyijing@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbaF0Ahm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 20:37:42 -0400
In-Reply-To: <1403670176-12072-1-git-send-email-wangyijing@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 25 Jun 2014 12:22:56 +0800

> MSI-X should use PCI_MSIX_FLAGS not PCI_MSI_FLAGS.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied, thanks.
