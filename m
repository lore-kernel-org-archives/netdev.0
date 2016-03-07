From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ethernet: Add missing MFD_SYSCON dependency on
 HAS_IOMEM
Date: Mon, 07 Mar 2016 14:45:18 -0500 (EST)
Message-ID: <20160307.144518.958364548062170994.davem@davemloft.net>
References: <1457053492-22391-1-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbcCGTpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:45:20 -0500
In-Reply-To: <1457053492-22391-1-git-send-email-k.kozlowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Fri, 04 Mar 2016 10:04:52 +0900

> The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
> direct dependencies.
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Applied.
