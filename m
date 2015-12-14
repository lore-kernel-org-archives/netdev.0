From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: wanxl: add pci_disable_device in case of error
Date: Mon, 14 Dec 2015 16:22:19 -0500 (EST)
Message-ID: <20151214.162219.1631096471928074532.davem@davemloft.net>
References: <1449862099-6256-1-git-send-email-saurabh.truth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: saurabh.truth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449862099-6256-1-git-send-email-saurabh.truth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Saurabh Sengar <saurabh.truth@gmail.com>
Date: Sat, 12 Dec 2015 00:58:19 +0530

> If there is 'no suitable DMA available' error, device should be disabled
> before returning
> 
> Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>

Applied to net-next, thanks.
