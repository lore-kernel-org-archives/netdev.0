From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fixed the pbl setting with DT
Date: Wed, 28 Aug 2013 17:44:27 -0400 (EDT)
Message-ID: <20130828.174427.535294508747975574.davem@davemloft.net>
References: <004f01cea093$9980e100$cc82a300$%an@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	kgene.kim@samsung.com
To: bh74.an@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326Ab3H1Vo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 17:44:28 -0400
In-Reply-To: <004f01cea093$9980e100$cc82a300$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>
Date: Sat, 24 Aug 2013 15:31:43 +0900

> This patch fixed the pbl(programmable burst length) setting 
> using DT. Even though the default pbl is 8, If there is no 
> pbl property in device tree file, pbl is set 0 and it causes 
> bandwidth degradation.
> 
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Applied, thank you.
