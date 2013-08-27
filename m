From: boris brezillon <b.brezillon@overkiz.com>
Subject: Re: [PATCH 0/2] net/cadence/macb: add support for dt phy definition
Date: Tue, 27 Aug 2013 11:13:59 +0200
Message-ID: <521C6DD7.8030308@overkiz.com>
References: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com> <20130826.160450.2176892065062148718.davem@davemloft.net> <521C586A.7080604@overkiz.com> <CAGVrzcYBT5aCmdaiGTm34kVu1UQssxB_EHvvj+t0phT58hcsZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nicolas.ferre@atmel.com,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcYBT5aCmdaiGTm34kVu1UQssxB_EHvvj+t0phT58hcsZQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/08/2013 11:07, Florian Fainelli wrote:
> Hello Boris,
>
> 2013/8/27 boris brezillon <b.brezillon@overkiz.com>:
>> Hello Dave,
>>
>>
>> On 26/08/2013 22:04, David Miller wrote:
>>> From: Boris BREZILLON <b.brezillon@overkiz.com>
>>> Date: Thu, 22 Aug 2013 17:56:20 +0200
>>>
>>>> This patch series adds support for ethernet phy definition using device
>>>> tree.
>>>>
>>>> This may help in moving some at91 boards to dt (some of them define an
>>>> interrupt pin).
>>>>
>>>> Tested on samad31ek.
>>> Series applied to net-next, thanks.
>> Could you apply, the 3rd version of this series instead ?
>>
>> It fixes one bug when no phy is discovered and use the appropriate address
>> for the phy dt node.
>>
>> Sorry for the inconvenience.
> You will probably have to resubmit an incremental patch, I have never
> seen David pick up another version of a patch once it has been pushed
> out:
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=8c038e7e14b1c5f156745e3c4df0a3aa46173dd9
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=148cbb53ace32f584d208764c7f7e6aa8edb970c
Okay, I will submit patches (based on net-next branch) to fix those bugs.

Thanks.

Best Regards,
Boris
