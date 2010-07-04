From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] IB/{nes,ipoib}: Pass supported flags to
 ethtool_op_set_flags()
Date: Sun, 04 Jul 2010 11:48:33 -0700 (PDT)
Message-ID: <20100704.114833.260086450.davem@davemloft.net>
References: <1278184884.4878.559.camel@localhost>
	<1278186089.4878.570.camel@localhost>
	<adask40nxaa.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, rolandd@cisco.com,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, sgruszka@redhat.com,
	amit.salecha@qlogic.com, amwang@redhat.com,
	anirban.chakraborty@qlogic.com, dm@chelsio.com, scofeldm@cisco.com,
	vkolluri@cisco.com, roprabhu@cisco.com,
	e1000-devel@lists.sourceforge.net, buytenh@wantstofly.org,
	gallatin@myri.com, brice@myri.com, shemminger@linux-foundation.org,
	jgarzik@redhat.com, faisal.latif@intel.com,
	chien.tin.tung@intel.com, linux-rdma@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757188Ab0GDSsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 14:48:20 -0400
In-Reply-To: <adask40nxaa.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Sat, 03 Jul 2010 13:08:29 -0700

>  > Following commit 1437ce3983bcbc0447a0dedcd644c14fe833d266 "ethtool:
>  > Change ethtool_op_set_flags to validate flags", ethtool_op_set_flags
>  > takes a third parameter and cannot be used directly as an
>  > implementation of ethtool_ops::set_flags.
> 
> Acked-by: Roland Dreier <rolandd@cisco.com>

Applied, thanks guys.
