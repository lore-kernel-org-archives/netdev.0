From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH 4/5] net: sh_eth: add CONFIG_SH_ETH_NUM_RXDESC option
Date: Fri, 16 Mar 2012 19:26:52 +0900
Message-ID: <4F63156C.2050400@renesas.com>
References: <4F62FDD8.9010907@renesas.com>
 <20120316.021117.1280920754044065090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <20120316.021117.1280920754044065090.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/03/16 18:11, David Miller wrote:
> From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
> Date: Fri, 16 Mar 2012 17:46:16 +0900
> 
>> This patch allows you to configure the number of RX descriptors.
>>
>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> 
> Never decide such things at compile time, use ethtool at runtime
> for this.
> 

Thank you for the review. I will fix this.

Best regards,
Yoshihiro Shimoda
