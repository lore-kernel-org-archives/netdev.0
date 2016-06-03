From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: remove unused priv lock
Date: Fri, 03 Jun 2016 19:43:55 -0400 (EDT)
Message-ID: <20160603.194355.1991992935038658411.davem@davemloft.net>
References: <1464907028-19622-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464907028-19622-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Fri,  3 Jun 2016 01:37:08 +0300

> There is no reason in this lock. At least for now.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied to net-next.
