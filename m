From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [PATCH v4 0/5] netdev: show a process of packets
Date: Fri, 03 Sep 2010 11:55:04 +0900
Message-ID: <4C806388.9020509@jp.fujitsu.com>
References: <4C72422C.5070102@jp.fujitsu.com>	<1283212210.3656.84.camel@gandalf.stny.rr.com>	<4C80592B.2060406@jp.fujitsu.com> <20100902.191741.233696520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	nhorman@tuxdriver.com, laijs@cn.fujitsu.com,
	scott.a.mcmillan@intel.com, eric.dumazet@gmail.com,
	fweisbec@gmail.com, mathieu.desnoyers@polymtl.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:60935 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755003Ab0ICCzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 22:55:21 -0400
In-Reply-To: <20100902.191741.233696520.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/09/03 11:17), David Miller wrote:
> From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> Date: Fri, 03 Sep 2010 11:10:51 +0900
> 
>> Thanks many acks. and I have one question.
>>
>> These patches have several component.
>>
>> Patch1 is kernel component, but patch2-5 are netdev component.
>> What tree is good to be included ?
>> If it is not net-next, I must rebase to another tree.
> 
> I would prefer it goes into the tracing tree or whatever is the most appropriate
> for patch #1.
> 

O.K. I'll rebase to linux-2.6-tip.

Thanks,
Koki Sanagi.

