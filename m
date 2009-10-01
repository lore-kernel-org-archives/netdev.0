From: David Miller <davem@davemloft.net>
Subject: Re: clownix-spy plots any kernel variable history
Date: Thu, 01 Oct 2009 14:31:59 -0700 (PDT)
Message-ID: <20091001.143159.62171955.davem@davemloft.net>
References: <1254432239.6772.1.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clownix@clownix.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39980
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753009AbZJAVbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:31:40 -0400
In-Reply-To: <1254432239.6772.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clownix <clownix@clownix.net>
Date: Thu, 01 Oct 2009 23:23:59 +0200

Netdev CC:'d

> I have made a tool at http://clownix.net which can plot qdisc
> enqueues/dequeues/drops...
> 
> But the qdisc spy is only given as an example, basically any kernel
> variable can be plotted after you have writen only a few lines in a
> module, in this module, you subscribe to the klownix module and then the
> klownix kernel thread periodically gathers the variables and sends them
> through the netlink socket to a user daemon. A gtk interface requests
> the plotting of the history of the variable.
> 
> The package contains a little test of visualization of the hfsc qdisc in
> action.
> 
> If you visit the clownix site, beware, the tool is not the Cloonix-Net
> which is another project altogether.
> 
> Regards
> Vincent Perrier
