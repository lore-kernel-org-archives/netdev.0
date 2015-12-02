From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] arm64: bpf: add 'store immediate' instruction
Date: Wed, 02 Dec 2015 15:42:55 -0500 (EST)
Message-ID: <20151202.154255.1517598326520827612.davem@davemloft.net>
References: <1448922247-5692-1-git-send-email-yang.shi@linaro.org>
	<565E1D38.7020906@linaro.org>
	<20151202091517.GA7311@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yang.shi@linaro.org, ast@kernel.org, catalin.marinas@arm.com,
	zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151202091517.GA7311@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Will Deacon <will.deacon@arm.com>
Date: Wed, 2 Dec 2015 09:15:18 +0000

> On Tue, Dec 01, 2015 at 02:20:40PM -0800, Shi, Yang wrote:
>> On 11/30/2015 2:24 PM, Yang Shi wrote:
>> >aarch64 doesn't have native store immediate instruction, such operation
>> >has to be implemented by the below instruction sequence:
>> >
>> >Load immediate to register
>> >Store register
>> >
>> >Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> >CC: Zi Shen Lim <zlim.lnx@gmail.com>
>> 
>> Had email exchange offline with Zi Shen Lim since he is traveling and cannot
>> send text-only mail, quoted below for his reply:
>> 
>> "I've given reviewed-by in response to original posting. Unless something
>> has changed, feel free to add it."
>> 
>> Since there is nothing changed, added his reviewed-by.
>> 
>> Reviewed-by: Zi Shen Lim <zlim.lnx@gmail.com>
> 
> I assume David will take this via netdev.

Yes, I will, thanks.
