From: Eric Preston <developer@linuxmontreal.com>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sun, 19 Aug 2007 19:04:37 -0400
Message-ID: <172AD054-448D-4085-82EE-AAEE77C0640F@linuxmontreal.com>
References: <20070818121714.GA28247@1wt.eu> <283388.84897.qm@web38905.mail.mud.yahoo.com> <20070819093221.4d3291e9@freepuppy.rosehill.hemminger.net> <2456F7EB-000C-4B71-B002-64340DD17BA8@linuxmontreal.com> <20070819113400.12f5570c@localhost>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server2.corp.notserp.com ([64.71.152.20]:4806 "EHLO
	server2.corp.notserp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbXHSXEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2007 19:04:44 -0400
In-Reply-To: <20070819113400.12f5570c@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 19-Aug-07, at 2:34 PM, Stephen Hemminger wrote:

> The driver prints some chip version info at startup, that might
> be helpful in disambiguating good/bad versions:
>
> 	dmesg | grep sky2

sky2 0000:03:00.0: v1.16 addr 0xfa000000 irq 16 Yukon-EC Ultra (0xb4)  
rev 2
sky2 eth0: addr XX:XX:XX:XX:XX
sky2 eth0: enabling interface
sky2 eth0: ram buffer 0K
sky2 eth0: disabling interface

-E

---
Eric Preston, RHCA, RHCSS, RHCE
Open Source Software Consultant // Administrator, Developer, Trainer
514-312-7072


