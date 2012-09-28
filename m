From: Haicheng Li <haicheng.li@linux.intel.com>
Subject: Re: [PATCH 2/2] Fix a typo in PTP_1588_CLOCK_PCH Kconfig help info.
Date: Fri, 28 Sep 2012 14:44:00 +0800
Message-ID: <50654730.6010204@linux.intel.com>
References: <506009A4.8000202@linux.intel.com>	<50600A49.7040902@linux.intel.com>	<5060F9C4.4050303@linux.intel.com> <20120927.180640.447002776076460117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tshimizu818@gmail.com,
	linux-kernel@vger.kernel.org, haicheng.lee@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120927.180640.447002776076460117.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2012 06:06 AM, David Miller wrote:
>> -	  will be called ptp_pch.
>> +	  will be called by pch_ptp.
>
> The original sentence is correct, it is stating the name of the module
> that will be built not the module that will call it.
You're right.

> Rather, the "pch_ptp" is what might need to be adjusted.
No need, the output is ptp_pch.ko.

So pls. ignore this patch. sorry for the bothering.

-haicheng
