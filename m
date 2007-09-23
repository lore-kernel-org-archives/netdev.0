From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCHES] TX batching
Date: Sun, 23 Sep 2007 14:19:04 -0400
Message-ID: <46F6AE18.7080708@garzik.org>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>	 <20070916.161748.48388692.davem@davemloft.net>	 <1189988958.4230.55.camel@localhost> <1190569987.4256.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40712 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756007AbXIWSTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2007 14:19:51 -0400
In-Reply-To: <1190569987.4256.52.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> More patches to follow  - i didnt want to overload people by dumping 
> too many patches. Most of these patches below are ready to go; some are
> need some testing and others need a little porting from an earlier
> kernel: 
> - tg3 driver (tested and works well, but dont want to send 
> - tun driver
> - pktgen
> - netiron driver
> - e1000 driver


You should post at least a couple driver patches to see how its used on 
Real Hardware(tm)...   :)

The batching idea has always seemed like a no-brainer to me, so I'm very 
interested to see how this turns out.

	Jeff


