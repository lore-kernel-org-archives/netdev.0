From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Multiple IPV6 Routing Tables & Policy Routing
Date: Fri, 28 Jul 2006 01:23:49 -0700 (PDT)
Message-ID: <20060728.012349.111204744.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060728.151009.54809236.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49843
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750760AbWG1IYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 04:24:11 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060728.151009.54809236.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 28 Jul 2006 15:10:09 +0900 (JST)

> Well, as you stated, the code is based on the work of MIPL,
> which is being jointly developed by Helsinki University of Technology (HUT)
> and USAGI/WIDE Project.  Please describe this on your commit logs.
> Please retain copyright information as well.

Ok.

Thomas could you please respin the patches with:

1) Updated credits, based upon Yoshifuji's feedback

2) Fixes for the small issues Patrick pointer out in
   his review

Thanks a lot.


