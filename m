From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Fri, 24 Aug 2007 09:25:20 -0700
Message-ID: <46CF0670.1050102@hp.com>
References: <46CC6DD1.5020105@hp.com>	<20070822.132145.90824527.davem@davemloft.net>	<1187906650.4279.16.camel@localhost>	<20070823.153047.99173582.davem@davemloft.net>	<1187908702.4279.36.camel@localhost> <20070823203425.2a32fb3f@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:58247 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761356AbXHXQ1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 12:27:17 -0400
In-Reply-To: <20070823203425.2a32fb3f@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> A current hot topic of research is reducing the number of ACK's to make TCP
> work better over asymmetric links like 3G.

Oy.  People running Solaris and HP-UX have been "researching" ACK reductions 
since 1997 if not earlier.

rick jones
