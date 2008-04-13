From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB and ingress scheduler SMP Soft Lockup in 2.6.23-2.6.25-rc8
Date: Sun, 13 Apr 2008 09:51:50 +0200
Message-ID: <4801BB96.5010406@trash.net>
References: <47FFAFFA.7070802@superclick.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Enrico Demarin <enrico@superclick.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36336 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbYDMHzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 03:55:14 -0400
In-Reply-To: <47FFAFFA.7070802@superclick.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Demarin wrote:
> Kernel message
> --------------
>
> BUG: soft lockup - CPU#0 stuck for 61s! 
> [tc:5667]                                               
> Pid: 5667, comm: tc Not tainted (2.6.25-rc8 
> #1)                                               EIP: 
> 0060:[<c0282564>] EFLAGS: 00000287 CPU: 
> 0                                              EIP is at 
> qdisc_lookup+0x21/0x4b                                EAX: f7261224 
> EBX: f7261000 ECX: f0de6300 EDX: 
> f0de634c                                                       ESI: 
> ffff0000 EDBUG: soft lockup - CPU#0 stuck for 61s!
 > ...

This is unfortunately almost unreadable. Please resend the message
as attachment.

