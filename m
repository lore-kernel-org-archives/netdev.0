From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: USAGI Kernel for MIPS based device
Date: Tue, 25 Feb 2003 19:55:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030225.195512.18953246.yoshfuji@linux-ipv6.org>
References: <20030225101731.9289.qmail@webmail14.rediffmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com, linux-mips@linux-mips.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ipv6_san@rediffmail.com
In-Reply-To: <20030225101731.9289.qmail@webmail14.rediffmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030225101731.9289.qmail@webmail14.rediffmail.com> (at 25 Feb 2003 10:17:31 -0000), "Santosh " <ipv6_san@rediffmail.com> says:

> Now i want to port latest USAGI kernel code onto my device.
:
> Is the USAGI code, platform independent ??

It should be.  We run our code on our
 - ix86
 - Ultra SPARC
 - Power PC
 - MIPS
 - ARM
machines.
(Unfortunately, we don't have x86-64, ia86 or alpha machines...)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
