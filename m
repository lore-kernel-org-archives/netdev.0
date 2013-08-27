From: boris brezillon <b.brezillon@overkiz.com>
Subject: Re: [PATCH 0/2] net/cadence/macb: add support for dt phy definition
Date: Tue, 27 Aug 2013 09:42:34 +0200
Message-ID: <521C586A.7080604@overkiz.com>
References: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com> <20130826.160450.2176892065062148718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, rob.herring@calxeda.com,
	pawel.moll@arm.com, mark.rutland@arm.com, swarren@wwwdotorg.org,
	ian.campbell@citrix.com, linux@arm.linux.org.uk,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130826.160450.2176892065062148718.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

On 26/08/2013 22:04, David Miller wrote:
> From: Boris BREZILLON <b.brezillon@overkiz.com>
> Date: Thu, 22 Aug 2013 17:56:20 +0200
>
>> This patch series adds support for ethernet phy definition using device
>> tree.
>>
>> This may help in moving some at91 boards to dt (some of them define an
>> interrupt pin).
>>
>> Tested on samad31ek.
> Series applied to net-next, thanks.
Could you apply, the 3rd version of this series instead ?

It fixes one bug when no phy is discovered and use the appropriate address
for the phy dt node.

Sorry for the inconvenience.

Best Regards,

Boris
