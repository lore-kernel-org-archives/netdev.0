From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC V4 0/2] Optimize the snmp stat aggregation for
 large cpus
Date: Sun, 30 Aug 2015 21:49:16 -0700 (PDT)
Message-ID: <20150830.214916.1137167975405435830.davem@davemloft.net>
References: <y>
	<1440914382-23126-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, edumazet@google.com,
	hannes@stressinduktion.org, tom@herbertland.com, azhou@nicira.com,
	ebiederm@xmission.com, ipm@chirality.org.uk,
	nicolas.dichtel@6wind.com, serge.hallyn@canonical.com,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: raghavendra.kt@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440914382-23126-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Date: Sun, 30 Aug 2015 11:29:40 +0530

> While creating 1000 containers, perf is showing lot of time spent in
> snmp_fold_field on a large cpu system.
> 
> The current patch tries to improve by reordering the statistics gathering.
 ...

Series applied, thanks.
