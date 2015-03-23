From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next 0/5] NetCP: Add support for version 1.5
Date: Mon, 23 Mar 2015 11:13:33 -0400
Message-ID: <55102D9D.3080802@ti.com>
References: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com> <20150320.220334.1613709882223685682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<prabhakar.csengg@gmail.com>, <grygorii.strashko@ti.com>,
	<cj@linux.com>, <lokeshvutla@ti.com>, <mpa@pengutronix.de>,
	<galak@codeaurora.org>, <ijc+devicetree@hellion.org.uk>,
	<mark.rutland@arm.com>, <pawel.moll@arm.com>, <robh+dt@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150320.220334.1613709882223685682.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2015 10:03 PM, David Miller wrote:
> From: Murali Karicheri<m-karicheri2@ti.com>
> Date: Fri, 20 Mar 2015 16:11:20 -0400
>
>> NetCP 1.5 is used in newer K2 SoCs from Texas Instruments
>> such as K2E, K2L etc. This patch series add support for Ethss
>> driver for this version of NetCP. While at it, fix couple of
>> bugs in the original driver.
>>
>> One of the earlier patch "net: netcp: select davinci_mdio driver
>> by default" is folded onto this series.
>>
>> Please review and let me know your comments.
>
> Series applied to net-next, thanks.
David,

Thanks for applying the series.

Regards,
-- 
Murali Karicheri
Linux Kernel, Texas Instruments
