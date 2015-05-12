From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ibm-emac: changes of emac_regs structure
 accordingly within driver emac_regs structure
Date: Tue, 12 May 2015 10:50:41 -0400 (EDT)
Message-ID: <20150512.105041.1963756474860108525.davem@davemloft.net>
References: <20150512171144.5eb73b65@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@decadent.org.uk
To: ivan@ru.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150512171144.5eb73b65@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Mikhaylov <ivan@ru.ibm.com>
Date: Tue, 12 May 2015 17:11:44 +0400

> In ibm_emac.c in ethtool size of emac structure which passing through to driver
> is nailed down and not correlating with current emac_regs structure.
> 
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>

Please do not submit patches for two different projects as a single
patch series.

Thank you.
