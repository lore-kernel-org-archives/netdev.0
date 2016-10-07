From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: axienet: Add missing \n to end of dev_err messages
Date: Thu, 06 Oct 2016 20:41:44 -0400 (EDT)
Message-ID: <20161006.204144.935332920047409761.davem@davemloft.net>
References: <20161004111141.11768-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161004111141.11768-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue,  4 Oct 2016 12:11:41 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Trival fix, dev_err messages are missing a \n, so add it.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
