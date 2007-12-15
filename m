From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24-rc5-mm1 -- inconsistent {in-softirq-W} -> {softirq-on-R}
   usage.
Date: Sat, 15 Dec 2007 18:06:35 +0100
Message-ID: <4764099B.2070804@gmail.com>
References: <a44ae5cd0712141413u4ddbfd06gca259cfc3bc0ab1a@mail.gmail.com>	<20071214153633.5d8f609a.akpm@linux-foundation.org>	<a44ae5cd0712141958o10d9a320h3b8173019ac6b0eb@mail.gmail.com> <20071215031341.66dc0d05.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Miles Lane <miles.lane@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:35046 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757957AbXLORAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 12:00:49 -0500
Received: by fg-out-1718.google.com with SMTP id e21so81507fga.17
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 09:00:48 -0800 (PST)
In-Reply-To: <20071215031341.66dc0d05.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 12/15/2007 12:13 PM:

> On Fri, 14 Dec 2007 22:58:24 -0500 "Miles Lane" <miles.lane@gmail.com> wrote:
> 
>> On Dec 14, 2007 6:36 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>>> On Fri, 14 Dec 2007 17:13:21 -0500
>>> "Miles Lane" <miles.lane@gmail.com> wrote:
...
>>>> Pid: 6944, comm: cat Not tainted (2.6.24-rc5-mm1 #26)

...

>>>> note: cat[6944] exited with preempt_count 4

...

>> Dec 14 21:32:55 feargod kernel: cat/6180 is trying to release lock

...

> Can you suggest a way in which others can reproduce this?

Buy a cat?

Jarek P.
