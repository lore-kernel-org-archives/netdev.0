From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Tue, 21 Aug 2007 15:50:00 -0700 (PDT)
Message-ID: <20070821.155000.98554047.davem@davemloft.net>
References: <1187699422.5324.41.camel@localhost>
	<20070821.115143.23013721.davem@davemloft.net>
	<1187730552.5324.76.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752239AbXHUWuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 18:50:03 -0400
In-Reply-To: <1187730552.5324.76.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 21 Aug 2007 17:09:12 -0400

> Examples, a busy ssh or irc server and you could go as far as
> looking at the most pre-dominant app on the wild west, http (average
> page size from a few years back was in the range of 10-20K and can
> be simulated with good ole netperf/iperf).

Pages have chunked up considerably in recent years.

Just bringing up a myspace page can give you megabytes of video,
images, flash, and other stuff.
