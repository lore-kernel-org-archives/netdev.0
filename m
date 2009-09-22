From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xilinx_emaclite: Fix problem with first incoming
 packet
Date: Tue, 22 Sep 2009 14:17:39 -0700 (PDT)
Message-ID: <20090922.141739.244623278.davem@davemloft.net>
References: <fac40d47-5b19-4225-9fee-f7a058851fc0@SG2EHSMHS017.ehs.local>
	<fa686aa40909220953g708445d9s9c25bd839cc2dd2e@mail.gmail.com>
	<20090922165612.584554A8052@mail195-sin.bigfish.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com,
	sadanan@xilinx.com, monstr@monstr.eu
To: John.Linn@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52078
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbZIVVRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:17:21 -0400
In-Reply-To: <20090922165612.584554A8052@mail195-sin.bigfish.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Linn <John.Linn@xilinx.com>
Date: Tue, 22 Sep 2009 10:56:27 -0600

> Thanks Grant, I wondered about that myself.

I've applied this patch, thanks.
