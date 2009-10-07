From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] bonding: introduce primary_reselect
 option
Date: Wed, 07 Oct 2009 01:25:40 -0700 (PDT)
Message-ID: <20091007.012540.251740594.davem@davemloft.net>
References: <20090918195358.GB32154@psychotron.redhat.com>
	<21492.1253838848@death.nxdomain.ibm.com>
	<20090925132803.GB3657@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, nicolas.2p.debian@free.fr
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758796AbZJGIZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:25:45 -0400
In-Reply-To: <20090925132803.GB3657@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 25 Sep 2009 15:28:09 +0200

> Subject: [PATCH net-2.6 v3] bonding: introduce primary_reselect option
> 
> In some cases there is not desirable to switch back to primary interface when
> it's link recovers and rather stay with currently active one. We need to avoid
> packetloss as much as we can in some cases. This is solved by introducing
> primary_reselect option. Note that enslaved primary slave is set as current
> active no matter what.
> 
> Patch modified by Jay Vosburgh as follows: fixed bug in action
> after change of option setting via sysfs, revised the documentation
> update, and bumped the bonding version number.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks.
