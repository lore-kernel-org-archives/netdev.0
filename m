From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v10 net-next 0/6] net: low latency Ethernet device polling
Date: Tue, 11 Jun 2013 15:49:32 +0300
Message-ID: <51B71CDC.1040004@linux.intel.com>
References: <51B68AA6.1050105@linux.intel.com> <20130610.212443.1096102996038709384.davem@davemloft.net> <51B6C87B.70101@linux.intel.com> <20130611.011427.2250431661196003301.davem@davemloft.net>
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
In-Reply-To: <20130611.011427.2250431661196003301.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/06/2013 11:14, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Tue, 11 Jun 2013 09:49:31 +0300
>
>> I would like to hear opinions on what needs to be added to make this
>> feature complete.
>
> I actually would like to see the Kconfig option go away, that's
> my only request.

OK,

I will send a patch for this when I submit the socket option patch.

-Eliezer
