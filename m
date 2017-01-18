From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: davinci_cpdma: correct check on
 NULL in set rate
Date: Wed, 18 Jan 2017 16:38:25 -0500 (EST)
Message-ID: <20170118.163825.1109172903256378954.davem@davemloft.net>
References: <1484699286-6197-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484699286-6197-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Wed, 18 Jan 2017 02:28:06 +0200

> Check "ch" on NULL first, then get ctlr.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied, thanks.
