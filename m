From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: xgene: change APM X-Gene SoC platform
 ethernet to support ACPI
Date: Fri, 19 Dec 2014 12:40:38 -0500 (EST)
Message-ID: <20141219.124038.1647232478583600202.davem@davemloft.net>
References: <1418945991-31494-1-git-send-email-fkan@apm.com>
	<20141219.123107.1080751255468272638.davem@davemloft.net>
	<CAL85gmCOLrcTijpEhXx1x5UjHu0sgS5DdGYJxY4mwPFKCHpU-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patches@apm.com,
	linux-kernel@vger.kernel.org
To: fkan@apm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL85gmCOLrcTijpEhXx1x5UjHu0sgS5DdGYJxY4mwPFKCHpU-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Feng Kan <fkan@apm.com>
Date: Fri, 19 Dec 2014 09:36:13 -0800

> On Fri, Dec 19, 2014 at 9:31 AM, David Miller <davem@davemloft.net> wrote:
>> From: Feng Kan <fkan@apm.com>
>> Date: Thu, 18 Dec 2014 15:39:51 -0800
>>
>>> +#define NO_MAC_FOUND 0
>>> +#define RES_ENET_CSR 0
>>> +#define RES_RING_CSR 1
>>> +#define RES_RING_CMD 2
> Is there a issue with the RES defines, do you prefer enum types?

I don't have any problem with those.
