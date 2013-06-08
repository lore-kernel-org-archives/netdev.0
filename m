From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v9 net-next 0/7] net: low latency Ethernet device polling
Date: Sat, 08 Jun 2013 21:06:38 +0300
Message-ID: <51B372AE.2080705@linux.intel.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com> <20130607.144805.1227746282017227022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130607.144805.1227746282017227022.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2013 00:48, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Wed, 05 Jun 2013 13:34:00 +0300
>
>> And here is v9.
>> Except for typo fixes in comments/description, only 2/7 and 5/7 were changed.
>>
>> Thanks to everyone for their input.
>
> Since there is some discussion about the way the poll() bits work,
> might I suggest you make a v10 without the poll stuff, which I will
> apply to net-next, and then you can build the poll stuff on top of
> that?

I will do that.

Thanks,
Eliezer
