From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re:
 [tproxy,regression] tproxy broken in 2.6.32
Date: Fri, 25 Dec 2009 17:30:42 -0800 (PST)
Message-ID: <20091225.173042.189687657.davem@davemloft.net>
References: <1260731716.6167.27.camel@bigi>
	<20091213.191024.193699730.davem@davemloft.net>
	<1260785985.6167.29.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, hidden@balabit.hu, kaber@trash.net, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33094
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757488AbZLZBak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 20:30:40 -0500
In-Reply-To: <1260785985.6167.29.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 14 Dec 2009 05:19:45 -0500

> On Sun, 2009-12-13 at 19:10 -0800, David Miller wrote:
> 
>> Don't use binary attachments like that please.
>> 
>> It doesn't end up in patchwork properly, and I need that to
>> happen in order to track people's work effectively.
> 
> That was me venturing into git-land. This is how i normally send them:

Applied, thanks Jamal.

I hope this puts the tproxy regression to rest :-)
