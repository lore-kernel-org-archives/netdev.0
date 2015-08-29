From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Fri, 28 Aug 2015 22:11:51 -0700 (PDT)
Message-ID: <20150828.221151.233357371571169851.davem@davemloft.net>
References: <55E00238.10909@linux.vnet.ibm.com>
	<20150828.112413.424099339331017970.davem@davemloft.net>
	<20150829025715.GA5546@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jiri@resnulli.us,
	hannes@stressinduktion.org, tom@herbertland.com, azhou@nicira.com,
	ebiederm@xmission.com, ipm@chirality.org.uk,
	nicolas.dichtel@6wind.com, serge.hallyn@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@au1.ibm.com, nacc@linux.vnet.ibm.com,
	srikar@linux.vnet.ibm.com
To: raghavendra.kt@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150829025715.GA5546@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Date: Sat, 29 Aug 2015 08:27:15 +0530

> resending the patch with memset. Please let me know if you want to
> resend all the patches.

Do not post patches as replies to existing discussion threads.

Instead, make a new, fresh, patch posting, updating the Subject line
as needed.
