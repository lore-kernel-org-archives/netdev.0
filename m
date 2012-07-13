From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Fri, 13 Jul 2012 08:50:07 -0700
Message-ID: <20120713085007.596a2924@nehalam.linuxnetplumber.net>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
	<20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
	<1342077259.3265.8232.camel@edumazet-glaptop>
	<4FFEEF99.7030707@intel.com>
	<1342165129.3265.8320.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56116 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab2GMPuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 11:50:25 -0400
In-Reply-To: <1342165129.3265.8320.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jul 2012 09:38:49 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Frankly what percentage of linux powered machines act as high perf
> routers ?

More than you think, every Linux machine acting as hypervisor (Xen and KVM)
is also doing this.
