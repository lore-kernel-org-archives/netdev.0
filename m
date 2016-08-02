From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1115/1285] Replace numeric parameter like 0444 with
 macro
Date: Tue, 02 Aug 2016 10:59:01 -0700 (PDT)
Message-ID: <20160802.105901.1278960621806579606.davem@davemloft.net>
References: <20160802121749.24461-1-baolex.ni@intel.com>
	<8737mns0qg.fsf@x220.int.ebiederm.org>
	<20160802174733.GB4628@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, baolex.ni@intel.com, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	johunt@akamai.com, vpai@akamai.com, chuansheng.liu@intel.com,
	aryabinin@virtuozzo.com
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160802174733.GB4628@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Tue, 2 Aug 2016 19:47:33 +0200

> But that does not make me like the series. And yes, hiding backdoor
> in one of those would be way too easy...

This is one of the worst patch series submissions in history.
At vger.kernel.org postmaster I just spent 45 minutes dealing
with the fallout.

1200+ patches all at once, unacceptable.

Every patch having the same Subject line text, unacceptable.

Triggering rate limiting bounces on %50+ of all lkml recipients,
unacceptable.

This is why you don't spam lists with a thousand patches.

If this is going to be properly submitted, it must be done in
reasonable, bite size, pieces of 10 to 15 patches at a time.
