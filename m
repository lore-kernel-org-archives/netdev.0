From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Linux-2.6.3 : [eth0: Too much work at interrupt,
 status=0x00000001.]
Date: Sat, 21 Feb 2004 03:20:06 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040221.032006.68375681.yoshfuji@linux-ipv6.org>
References: <200402201803.12146.andrew@walrond.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: andrew@walrond.org, netdev@oss.sgi.com
In-Reply-To: <200402201803.12146.andrew@walrond.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200402201803.12146.andrew@walrond.org> (at Fri, 20 Feb 2004 18:03:11 +0000), Andrew Walrond <andrew@walrond.org> says:

> I'm getting loads of these messages in dmesg.
> 
> This is a vanilla 2.6.3 kernel with ACPI disabled with acpi=off boot 
> parameter. No preempt, APIC and IOAPIC enabled
> 
> Its a single 2Ghz celeron with Via chipset and Rhine II ethernet. It is under 
> no load at all. ssh only.
> 
> dmesg is short and follows; Any knowledge apprieciated!
:
> eth0: Too much work at interrupt, status=0x00000001.

I've got this several times, randomly, and
I had to go to the console to reboot the machine.

Well, sorry, I haven't tracked it down yet...

Others?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
