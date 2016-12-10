From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] net: ethernet: ti: cpsw: don't start queue twice
Date: Sat, 10 Dec 2016 17:30:31 -0500 (EST)
Message-ID: <20161210.173031.384381478008823380.davem@davemloft.net>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
        <1481372630-14914-3-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481372630-14914-3-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Sat, 10 Dec 2016 14:23:47 +0200

> No need to start queues after cpsw is started as it will be done
> while cpsw_adjust_link(), after phy connection.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
