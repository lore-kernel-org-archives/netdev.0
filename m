From: Marc Aurele La France <tsi@ualberta.ca>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Fri, 27 Aug 2010 11:53:00 -0600 (Mountain Daylight Time)
Message-ID: <alpine.WNT.2.00.1008271149330.1120@cluij.ucs.ualberta.ca>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca> <20100823080543.319143e3@nehalam> <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca> <1282672647.2302.15.camel@achroite.uk.solarflarecom.com> <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
 <1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510> <alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca> <1282823827.2476.663.camel@edumazet-laptop> <alpine.WNT.2.00.1008260835020.2008@cluij.ucs.ualberta.ca> <20100826165359.3b79b27d@nehalam>
 <adaiq2w2fk0.fsf@cisco.com> <adaeidk2cyo.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.srv.ualberta.ca ([129.128.5.19]:59445 "EHLO
	mail7.srv.ualberta.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750983Ab0H0Rx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 13:53:56 -0400
In-Reply-To: <adaeidk2cyo.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Aug 2010, Roland Dreier wrote:

> By the way, for the original poster: is using NFS/RDMA a possibility?
> That might give even better performance than any config of IPoIB if you
> have an InfiniBand fabric anyway.

Yes, NFS/RDMA is a possibility I need to look at as well.

Thanks.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
