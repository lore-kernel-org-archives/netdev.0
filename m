From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ICMP: ICMP_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 03:25:54 -0800 (PST)
Message-ID: <20080121.032554.96053463.davem@davemloft.net>
References: <478DD57B.6020503@cn.fujitsu.com>
	<47947EBB.2020507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48158
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758920AbYAULZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 06:25:48 -0500
In-Reply-To: <47947EBB.2020507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 21 Jan 2008 19:15:07 +0800

> Dave, how about this one.
> It's like that one of IPV6.

I am confused, this changelog for this patch mentions changes made
only in the net-2.6.25 tree.

Yet you just told me the two other patches should be applied to
net-2.6

What is the exact story here?

Thank you.
