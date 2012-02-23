From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] phy: IC+101G and PHY_HAS_INTERRUPT flag
Date: Thu, 23 Feb 2012 17:14:46 -0500 (EST)
Message-ID: <20120223.171446.1085247355852159197.davem@davemloft.net>
References: <1329895498-5810-1-git-send-email-peppe.cavallaro@st.com>
	<1329895588-6191-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471Ab2BWWOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 17:14:51 -0500
In-Reply-To: <1329895588-6191-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 22 Feb 2012 08:26:28 +0100

> This patch adds the PHY_HAS_INTERRUPT flag for IC+101 device series.
> Also the patch does a simple dity-up to signal that
> the driver actually is for IP101A LF and IP101G devices.
> In fact, these are two similar PHYs that have the same IDs
> and mainly differ for the EEE capability supported in the
> G series.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
