From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] cpsw: add per channel shaper configuration
Date: Wed, 30 Nov 2016 14:37:30 -0500 (EST)
Message-ID: <20161130.143730.198414925220029543.davem@davemloft.net>
References: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Tue, 29 Nov 2016 17:00:46 +0200

> This series is intended to allow user to set rate for per channel
> shapers at cpdma level. This patchset doesn't have impact on performance.
> The rate can be set with:
> 
> echo 100 > /sys/class/net/ethX/queues/tx-0/tx_maxrate
> 
> Tested on am572xx
> Based on net-next/master

Series applied, thanks.
