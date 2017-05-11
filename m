From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: netcp_core: return error while dma
 channel open issue
Date: Thu, 11 May 2017 12:40:00 -0400 (EDT)
Message-ID: <20170511.124000.1534930712708208063.davem@davemloft.net>
References: <1494437285-13839-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, ssantosh@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494437285-13839-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Wed, 10 May 2017 10:28:05 -0700

> Fix error path while dma open channel issue. Also, no need to check output
> on NULL if it's never returned.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
