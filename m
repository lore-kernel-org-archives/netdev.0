From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] altera_tse: Correct typo in obtaining
 tx_fifo_depth from devicetree
Date: Mon, 23 Feb 2015 18:07:55 -0500 (EST)
Message-ID: <20150223.180755.580915891894434403.davem@davemloft.net>
References: <1424712457-24291-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org, vbridger@altera.com, setka@vsis.cz
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424712457-24291-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Mon, 23 Feb 2015 11:27:37 -0600

> From: Vlastimil Setka <setka@vsis.cz>
> 
> This patch corrects a typo in the way tx_fifo_depth is read from the
> devicetree. This patch was submitted by Vlastimil about a week ago,
> and is now cleaned up and resubmitted.
> 
> Signed-off-by: Vlastimil Setka <setka@vsis.cz>
> Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>

This is a bug fix, so I'm applying it to 'net'.

Thanks.
