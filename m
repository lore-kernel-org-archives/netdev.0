From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: qualcomm: rmnet: remove unused variable
 priv
Date: Fri, 01 Sep 2017 18:34:52 -0700 (PDT)
Message-ID: <20170901.183452.1095616327099284759.davem@davemloft.net>
References: <20170831140727.28170-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831140727.28170-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 31 Aug 2017 15:07:27 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> priv is being assigned but is never used, so remove it.
> 
> Cleans up clang build warning:
> "warning: Value stored to 'priv' is never read"
> 
> Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
