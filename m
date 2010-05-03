From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix arp_validate on bonds inside a bridge
Date: Mon, 03 May 2010 15:58:20 -0700 (PDT)
Message-ID: <20100503.155820.158442623.davem@davemloft.net>
References: <20100429163921.GA4228@midget.suse.cz>
	<26811.1272567443@death.nxdomain.ibm.com>
	<20100430154529.GB15803@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759663Ab0ECW6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:58:13 -0400
In-Reply-To: <20100430154529.GB15803@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 30 Apr 2010 17:45:29 +0200

> On Thu, Apr 29, 2010 at 11:57:23AM -0700, Jay Vosburgh wrote:
>> 	This doesn't apply to the current net-next-2.6 (because
>> skb_bond_should_drop was pulled out of line a few weeks ago); can you
>> update the patch?
> 
> sure, here it goes:

Jay can I get an ACK or similar?

Thanks.
