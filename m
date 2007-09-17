From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10 REV5] Implement skb batching and support in
 IPoIB/E1000
Date: Sun, 16 Sep 2007 18:02:32 -0700 (PDT)
Message-ID: <20070916.180232.101592975.davem@davemloft.net>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752252AbXIQBCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 21:02:33 -0400
In-Reply-To: <1189988958.4230.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Sun, 16 Sep 2007 20:29:18 -0400

> On Sun, 2007-16-09 at 16:17 -0700, David Miller wrote:
> 
> > The only major complaint I have about this patch series is that
> > the IPoIB part should just be one big changeset. 
> 
> Dave, you do realize that i have been investing my time working on
> batching as well, right? 

I do.

And I'm reviewing and applying several hundred patches a day.

What's the point? :-)
