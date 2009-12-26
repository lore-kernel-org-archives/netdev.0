From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re:
 [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 26 Dec 2009 13:45:18 -0800 (PST)
Message-ID: <20091226.134518.70179923.davem@davemloft.net>
References: <1260785985.6167.29.camel@bigi>
	<20091225.173042.189687657.davem@davemloft.net>
	<1261839914.3540.0.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, hidden@balabit.hu, kaber@trash.net, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752215AbZLZVpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 16:45:16 -0500
In-Reply-To: <1261839914.3540.0.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sat, 26 Dec 2009 10:05:14 -0500

> On Fri, 2009-12-25 at 17:30 -0800, David Miller wrote:
> 
>> I hope this puts the tproxy regression to rest :-)
> 
> It should. The only open question is whether this is considered
> a "bug fix" and needs to be propagated to -stable.

I do intend to send it there, so I do consider it a bug fix.
