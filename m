From: Massimo Cetra <ctrix+debianbugs@navynet.it>
Subject: Re: fake rtable dst patch applied but kernel keeps panicing
Date: Thu, 19 Apr 2012 12:52:35 +0200
Message-ID: <4F8FEE73.8030600@navynet.it>
References: <4F8E9291.9000607@navynet.it>	 <1334745072.2472.110.camel@edumazet-glaptop>  <4F8FC66F.90703@navynet.it>	 <1334823256.2395.2.camel@edumazet-glaptop> <1334825108.2395.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	netdev@vger.kernel.org, peter.huangpeng@huawei.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host188-6-static.238-77-b.business.telecomitalia.it ([77.238.6.188]:51671
	"EHLO max.ctrix.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab2DSKwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 06:52:43 -0400
In-Reply-To: <1334825108.2395.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/2012 10:45, Eric Dumazet wrote:

>> Maybe you should try latest kernel, because we fixed some bugs lately.
>
> Oh well, at first glance nf_bridge_unshare() is buggy, not sure if this
> can help your bug, but its another step.
>

I'm recompiling 3.3.2 with this new patch.
I'll let you know.

Thanks you,

  Massimo
