From: David Miller <davem@davemloft.net>
Subject: Re: veth regression with =?iso-8859-7?B?ImRvbqJ0?= modify
 ip_summed; doing so treats packets with bad checksums as good."
Date: Fri, 25 Mar 2016 12:45:29 -0400 (EDT)
Message-ID: <20160325.124529.2108561053159019972.davem@davemloft.net>
References: <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
	<56F56312.4080408@candelatech.com>
	<CAM_iQpXpqVgweZFw438v_b7No8U8YtqHSt0x0+HZ+oSimdCyfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, vijayp@vijayp.ca, netdev@vger.kernel.org,
	ej@evanjones.ca, cwang@twopensource.com, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbcCYQpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 12:45:32 -0400
In-Reply-To: <CAM_iQpXpqVgweZFw438v_b7No8U8YtqHSt0x0+HZ+oSimdCyfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 25 Mar 2016 09:32:23 -0700

> So I believe dm9000 needs to fix.

+1
