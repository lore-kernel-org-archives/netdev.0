From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Wed, 09 Dec 2015 15:58:13 -0500 (EST)
Message-ID: <20151209.155813.321840735475652944.davem@davemloft.net>
References: <1449529094-10922-1-git-send-email-gavidov@codeaurora.org>
	<CAOZdJXXQKMrOJpm3XJmX5ZULEoOZqS12u5FWKdcxfUm+LnGbww@mail.gmail.com>
	<CAOMZO5CDb=mypVxrrCT-jkWxQnp6KXk7eek+AMWcbZ7+b7aGxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur@codeaurora.org, gavidov@codeaurora.org,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	sdharia@codeaurora.org, linux-arm-msm@vger.kernel.org,
	linux-kernel@vger.kernel.org, vikrams@codeaurora.org,
	shankerd@codeaurora.org
To: festevam@gmail.com
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5CDb=mypVxrrCT-jkWxQnp6KXk7eek+AMWcbZ7+b7aGxg@mail.gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabio Estevam <festevam@gmail.com>
Date: Wed, 9 Dec 2015 18:37:35 -0200

> On Wed, Dec 9, 2015 at 6:09 PM, Timur Tabi <timur@codeaurora.org> wrote:
> 
>>> +/* set MAC address */
>>> +void emac_mac_addr_clear(struct emac_adapter *adpt, u8 *addr)
>>> +{
>>> +       u32 sta;
>>> +
>>> +       /* for example: 00-A0-C6-11-22-33
>>> +        * 0<-->C6112233, 1<-->00A0.
>>> +        */
>>
>> /*
>>  * Multi-line comments
>>  * look like this.
>>  */
> 
> Except in drivers/net. The convention in drivers/net is to use
> multi-line format as posted in this patch.

Correct.
