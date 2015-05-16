From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] ipv6: fix ECMP route replacement
Date: Sat, 16 May 2015 17:18:23 -0400 (EDT)
Message-ID: <20150516.171823.1391641644498357985.davem@davemloft.net>
References: <20150515085151.GA32190@unicorn.suse.cz>
	<20150515.121212.20831661856896659.davem@davemloft.net>
	<20150515174156.GB32190@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	roopa@cumulusnetworks.com
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150515174156.GB32190@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 15 May 2015 19:41:56 +0200

> The semantics I suggested in my previous mail might be a reasonable
> approximation.

Ok, then let's try for that.
