From: David Miller <davem@davemloft.net>
Subject: Re: [RFCv4 PATCH 1/2] net: Introduce recvmmsg socket syscall
Date: Fri, 09 Oct 2009 14:27:51 -0700 (PDT)
Message-ID: <20091009.142751.142357109.davem@davemloft.net>
References: <20090916170738.GC7699@ghostprotocols.net>
	<20091009193520.GD12982@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlin.bestler@gmail.com, vanhoof@redhat.com, williams@redhat.com,
	nhorman@tuxdriver.com, nir.tzachar@gmail.com, niv@us.ibm.com,
	paul.moore@hp.com, remi.denis-courmont@nokia.com,
	steve@chygwyn.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760800AbZJIV14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 17:27:56 -0400
In-Reply-To: <20091009193520.GD12982@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 9 Oct 2009 16:35:20 -0300

> 	The second patch in this series has issues, I still have to
> investigate it properly, study removing the skb_queue_head lock like TCP
> does, but the first patch seems to be OK and already providing good
> results at least as reported by Nir, if there aren't any other concerns
> about the API, can we get it into net-next-2.6?

Please make a formal submission of that first patch with all proper
signoffs and without the "RFC" in the subject line and I'll apply it.

Thanks!
