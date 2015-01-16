From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sxgbe: Fix NULL dereferece when using DT
Date: Thu, 15 Jan 2015 19:14:10 -0500 (EST)
Message-ID: <20150115.191410.286404790933057959.davem@davemloft.net>
References: <1421286107-9514-1-git-send-email-kgene@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.ne, ks.giri@samsung.com,
	bh74.an@samsung.com
To: kgene@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309AbbAPAON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 19:14:13 -0500
In-Reply-To: <1421286107-9514-1-git-send-email-kgene@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kukjin Kim <kgene@kernel.org>
Date: Thu, 15 Jan 2015 10:41:47 +0900

> From: Girish K.S <ks.giri@samsung.com>
> 
> When the MAC address is provided in the device tree file, the
> condition is true and kernel crashes due to NULL dereference.
> 
> Signed-off-by: Girish K.S <ks.giri@samsung.com>
> Signed-off-by: Byungho An <bh74.an@samsung.com>
> Signed-off-by: Kukjin Kim <kgene@kernel.org>

Applied.
