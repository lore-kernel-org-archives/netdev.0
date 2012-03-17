From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] stmmac: Add device-tree support
Date: Fri, 16 Mar 2012 22:49:15 -0700 (PDT)
Message-ID: <20120316.224915.680873475462715286.davem@davemloft.net>
References: <1331650597-16747-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@ozlabs.org,
	spear-devel@list.st.com, peppe.cavallaro@st.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513Ab2CQFwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 01:52:36 -0400
In-Reply-To: <1331650597-16747-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Tue, 13 Mar 2012 15:56:37 +0100

> This patch adds support to configure the STMMAC ethernet driver via
> device-tree instead of platform_data.
> 
> Currently, only the properties needed on SPEAr600 are provided. All
> other properties should be added once needed on other platforms.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
