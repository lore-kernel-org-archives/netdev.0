From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:xen-netback - Change 1 to true for bool type
 variable.
Date: Mon, 25 May 2015 16:34:53 -0400 (EDT)
Message-ID: <20150525.163453.1087994839625386069.davem@davemloft.net>
References: <1432576171-3563-1-git-send-email-shailendra.capricorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shailendra.capricorn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432576171-3563-1-git-send-email-shailendra.capricorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shailendra Verma <shailendra.capricorn@gmail.com>
Date: Mon, 25 May 2015 23:19:31 +0530

> The variable separate_tx_rx_irq is bool type so assigning true
> instead of 1.
> 
> Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>

Applied.
