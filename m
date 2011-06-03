From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ftrace: tracepoint of net_dev_xmit sees freed skb and
 causes panic
Date: Thu, 02 Jun 2011 22:23:56 -0700 (PDT)
Message-ID: <20110602.222356.1588943715309944982.davem@davemloft.net>
References: <1307048512.3667.28.camel@gandalf.stny.rr.com>
	<20110602.140426.765650914977149734.davem@davemloft.net>
	<4DE86B37.4070704@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, mingo@elte.hu,
	fweisbec@gmail.com, mathieu.desnoyers@efficios.com,
	tglx@linutronix.de, kosaki.motohiro@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: sanagi.koki@jp.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DE86B37.4070704@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Date: Fri, 03 Jun 2011 14:03:51 +0900

> I will resubmit this patch with appropriate subject "net/tracing:"

You don't need to, I fixed it up when I applied your patch.
