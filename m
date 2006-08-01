From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 01 Aug 2006 14:57:05 -0700 (PDT)
Message-ID: <20060801.145705.71091996.davem@davemloft.net>
References: <200608010231.58339.ak@suse.de>
	<20060731.174641.99457765.davem@davemloft.net>
	<20060801120003.GY8334@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37309
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751157AbWHAV5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:57:06 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060801120003.GY8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hugo Santos <hsantos@av.it.pt>
Date: Tue, 1 Aug 2006 13:00:03 +0100

>  Resiliency to failure is not something that depends on the
>  kernel. If the code in question is in the kernel, and it crashes,
>  how will you recover?

Developer momentum means that the kernel is likely to get fixed
whereas the userland component will more likely rot and not get
fixed.

So in this sense resiliency does depend upon something being in
the kernel or not.
