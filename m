From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Wed, 21 Feb 2007 01:30:31 -0800 (PST)
Message-ID: <20070221.013031.48806156.davem@davemloft.net>
References: <20070221.040259.60395625.yoshfuji@linux-ipv6.org>
	<20070221.000222.71087924.davem@davemloft.net>
	<20070221.171545.35764627.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161162AbXBUJae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 04:30:34 -0500
In-Reply-To: <20070221.171545.35764627.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 21 Feb 2007 17:15:45 +0900 (JST)

> In article <20070221.000222.71087924.davem@davemloft.net> (at Wed, 21 Feb 2007 00:02:22 -0800 (PST)), David Miller <davem@davemloft.net> says:
> 
> > > So, I think it is ready. Here's my sign-off:
> > > 
> > > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > 
> > Neil, please keep this patch ready for the next merge window.
> 
> Dave, Neil,
> 
> I expect to have some changes in routing code in near future,
> I want to have Neil's change in my -dev tree, if you don't mind.

I have no problem with this, and I am sure Neil will be OK
with it too.
