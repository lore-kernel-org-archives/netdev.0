From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [PATCH] ftrace: tracepoint of net_dev_xmit sees freed skb and
 causes panic
Date: Fri, 03 Jun 2011 14:57:53 +0900
Message-ID: <4DE877E1.7000606@jp.fujitsu.com>
References: <1307048512.3667.28.camel@gandalf.stny.rr.com>	<20110602.140426.765650914977149734.davem@davemloft.net>	<4DE86B37.4070704@jp.fujitsu.com> <20110602.222356.1588943715309944982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, mingo@elte.hu,
	fweisbec@gmail.com, mathieu.desnoyers@efficios.com,
	tglx@linutronix.de, kosaki.motohiro@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:40335 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab1FCF5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 01:57:49 -0400
In-Reply-To: <20110602.222356.1588943715309944982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2011/06/03 14:23), David Miller wrote:
> From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> Date: Fri, 03 Jun 2011 14:03:51 +0900
> 
>> I will resubmit this patch with appropriate subject "net/tracing:"
> 
> You don't need to, I fixed it up when I applied your patch.
> 

O.K.

Thanks!
Koki Sanagi
 


