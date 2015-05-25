From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ibm/emac: fix size of emac dump memory areas
Date: Mon, 25 May 2015 16:39:17 -0400 (EDT)
Message-ID: <20150525.163917.675144313058208503.davem@davemloft.net>
References: <20150521191102.45bd4a18@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	benh@kernel.crashing.org
To: ivan@ru.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150521191102.45bd4a18@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Mikhaylov <ivan@ru.ibm.com>
Date: Thu, 21 May 2015 19:11:02 +0400

> Fix in send of emac regs dump to ethtool which
> causing in wrong data interpretation on ethtool
> layer for MII and EMAC.
> 
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>

Applied, thanks.
