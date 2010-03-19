From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/3] bonding: refuse to change bond type
 if it's used V3
Date: Thu, 18 Mar 2010 20:05:14 -0700 (PDT)
Message-ID: <20100318.200514.48485837.davem@davemloft.net>
References: <20100310202804.GC2834@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net,
	shemminger@linux-foundation.org, kaber@trash.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46337
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750999Ab0CSDEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 23:04:52 -0400
In-Reply-To: <20100310202804.GC2834@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 10 Mar 2010 21:28:04 +0100

> v2->v3:
> -changed defines name to NETDEV_[PRE/POST]_TYPE_CHANGE
> -added bits for vlan and macvlan
> 
> Reworked version of patch/patchset. This time I use netdevice notifier as
> Stephen suggested. Changed the name of the original ones (NETDEV_BONDING_*TYPE)
> to be more general and reused them.

This looks really nice, applied thanks Jiri.

I know a lot of people who would have noticed this and
just said "not my problem" and gone on to work on something
else.  Instead you stopped and fixed it, and this is very
much appreciated.

Thanks again!
