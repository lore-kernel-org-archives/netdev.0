From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ICMP: ICMP_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 03:40:14 -0800 (PST)
Message-ID: <20080121.034014.263253207.davem@davemloft.net>
References: <47947EBB.2020507@cn.fujitsu.com>
	<20080121.032554.96053463.davem@davemloft.net>
	<47948360.9090709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759154AbYAULkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 06:40:09 -0500
In-Reply-To: <47948360.9090709@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 21 Jan 2008 19:34:56 +0800

> David Miller said the following on 2008-1-21 19:25:
> > I am confused, this changelog for this patch mentions changes made
> > only in the net-2.6.25 tree.
> > 
> 
> Although I wrote that I find David.S's patch in net-2.6.25 was wrong,
> the guilty patch also in net-2.6 tree. Here is the web link.
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=96793b482540f3a26e2188eaf75cb56b7829d3e3 
> 
> So, I think apply my patches to net-2.6 is ok.

Thank you for explaining this.

Patch applied to net-2.6
