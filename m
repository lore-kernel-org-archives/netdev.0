From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Mon, 16 Jan 2012 15:07:05 -0800
Message-ID: <4F14AD99.80905@linux.intel.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com> <20120114.001525.2158050844390627233.davem@davemloft.net> <20120116152239.GA9953@elliptictech.com> <20120116.180433.986989348820850613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nbowler@elliptictech.com, linux-kernel@vger.kernel.org,
	arjan@linux.intel.com, alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120116.180433.986989348820850613.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/16/2012 03:04 PM, David Miller wrote:
> From: Nick Bowler <nbowler@elliptictech.com>
> Date: Mon, 16 Jan 2012 10:22:39 -0500
> 
>> On 2012-01-14 00:15 -0800, David Miller wrote:
>>> From: Darren Hart <dvhart@linux.intel.com>
>>> Date: Fri, 13 Jan 2012 22:44:55 -0800
>>>
>>>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com> (commit_signer:1/3=33%,commit_signer:1/8=12%)
>>>
>>> BTW, please try to figure out where this "commit_signer" stuff came from.
>>>
>>> It ended up corrupting the CC: list of your posting too.
>>
>> While it ended up on the CC line, the result is still a valid and
>> correct email address per RFC 822.
> 
> I didn't say it wasn't an "RFC compliant" email address, I just said
> it's complete garbage.

Indeed. An oversight on my part and I've addressed it. Apologies for the
noise.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
