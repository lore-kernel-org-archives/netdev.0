From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: extend limits for
 cpsw_get/set_ringparam
Date: Mon, 09 Jan 2017 14:29:20 -0500 (EST)
Message-ID: <20170109.142920.729854911308845027.davem@davemloft.net>
References: <1483906347-7567-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
        linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483906347-7567-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Sun,  8 Jan 2017 22:12:27 +0200

> Allow to set number of descs close to possible values. In case of
> minimum limit it's equal to number of channels to be able to set
> at least one desc per channel. For maximum limit leave enough descs
> number for tx channels.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied, thank you.
