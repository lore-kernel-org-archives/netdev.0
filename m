From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Wed, 9 Dec 2015 18:37:35 -0200
Message-ID: <CAOMZO5CDb=mypVxrrCT-jkWxQnp6KXk7eek+AMWcbZ7+b7aGxg@mail.gmail.com>
References: <1449529094-10922-1-git-send-email-gavidov@codeaurora.org>
	<CAOZdJXXQKMrOJpm3XJmX5ZULEoOZqS12u5FWKdcxfUm+LnGbww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gilad Avidov <gavidov@codeaurora.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	sdharia@codeaurora.org, linux-arm-msm@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, vikrams@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <CAOZdJXXQKMrOJpm3XJmX5ZULEoOZqS12u5FWKdcxfUm+LnGbww@mail.gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 9, 2015 at 6:09 PM, Timur Tabi <timur@codeaurora.org> wrote:

>> +/* set MAC address */
>> +void emac_mac_addr_clear(struct emac_adapter *adpt, u8 *addr)
>> +{
>> +       u32 sta;
>> +
>> +       /* for example: 00-A0-C6-11-22-33
>> +        * 0<-->C6112233, 1<-->00A0.
>> +        */
>
> /*
>  * Multi-line comments
>  * look like this.
>  */

Except in drivers/net. The convention in drivers/net is to use
multi-line format as posted in this patch.
