From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] r8169:fix 3 runtime pm related issues.
Date: Sun, 31 Jul 2016 20:34:18 -0700 (PDT)
Message-ID: <20160731.203418.646652194893214741.davem@davemloft.net>
References: <1469781476-7692-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbcHADej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 23:34:39 -0400
In-Reply-To: <1469781476-7692-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chunhao Lin <hau@realtek.com>
Date: Fri, 29 Jul 2016 16:37:53 +0800

> v2:
> use "struct device *d = &tp->pci_dev->dev" instead of "struct pci_dev *pdev = tp->pci_dev"
> 
> v1:
> This series of patches fix 3 runtime pm related issues that are listed below.

Series applied, thanks.
