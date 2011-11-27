From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 7/8] bnx2x: Fix self test of BCM57800
Date: Sun, 27 Nov 2011 17:03:33 -0500 (EST)
Message-ID: <20111127.170333.1446126489386263223.davem@davemloft.net>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
	<1322417881-17760-8-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387Ab1K0WDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:03:37 -0500
In-Reply-To: <1322417881-17760-8-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Sun, 27 Nov 2011 20:18:00 +0200

> +			int cfg_idx = bnx2x_get_link_cfg_idx(bp);
> +			if (bp->port.supported[cfg_idx] &
> +			    (SUPPORTED_10000baseT_Full |
> +				 SUPPORTED_20000baseMLD2_Full |
> +				 SUPPORTED_20000baseKR2_Full))

Bad tab alignment, again.
