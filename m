From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Tue, 30 Aug 2005 10:56:28 +0100
Message-ID: <43142D4C.6030804@gentoo.org>
References: <20050830083512.39846.qmail@web53603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750880AbVH3J4f@vger.kernel.org>
To: Steve Kieu <haiquy@yahoo.com>
In-Reply-To: <20050830083512.39846.qmail@web53603.mail.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Kieu wrote:
> Ok it sound wierd enough to assume that the latest
> kernel 2.6.13 ethernet driver has done something wrong
> with the NIC and sustain the condition after reboot or
> turn off the machine.
> 
> Here is my configuration.
> 
> Laptop Asus A4500d. dmesg shows:
> 
> eth0: Yukon Gigabit Ethernet 10/100/1000Base-T Adapter

Are you using skge or sk98lin?

> It is working as normal with 2.6.12 and winXP before.
> Today I did upgrade the kernel to 2.6.13 and it still
> works. The problem is now I switch to the older kernel
> that is 2.6.12.5 and .6  it no longer works. dmesg
> shows like this:
>      
> eth0: Yukon Gigabit Ethernet 10/100/1000Base-T Adapter
>       PrefPort:A  RlmtMode:Check Link State
> 
> 
> Boot window XP now, and the link always shows that
> media disconnected. So the NIC is unuseable with
> WinXP, 2.6.12  __but__ still works with 2.6.13. and
> power off the machine does not restore the NIC. 
