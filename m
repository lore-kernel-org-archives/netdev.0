From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Wed, 21 Feb 2007 17:15:45 +0900 (JST)
Message-ID: <20070221.171545.35764627.yoshfuji@linux-ipv6.org>
References: <20070214.064649.06517604.yoshfuji@linux-ipv6.org>
	<20070221.040259.60395625.yoshfuji@linux-ipv6.org>
	<20070221.000222.71087924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:56902 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161125AbXBUIPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 03:15:35 -0500
In-Reply-To: <20070221.000222.71087924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070221.000222.71087924.davem@davemloft.net> (at Wed, 21 Feb 2007 00:02:22 -0800 (PST)), David Miller <davem@davemloft.net> says:

> > So, I think it is ready. Here's my sign-off:
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Neil, please keep this patch ready for the next merge window.

Dave, Neil,

I expect to have some changes in routing code in near future,
I want to have Neil's change in my -dev tree, if you don't mind.

--yoshfuji
