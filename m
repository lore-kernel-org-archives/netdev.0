From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Wed, 22 Aug 2007 13:21:45 -0700 (PDT)
Message-ID: <20070822.132145.90824527.davem@davemloft.net>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	<20070821.212229.82050253.davem@davemloft.net>
	<46CC6DD1.5020105@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753157AbXHVUVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:21:47 -0400
In-Reply-To: <46CC6DD1.5020105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 22 Aug 2007 10:09:37 -0700

> Should it be any more or less worrysome than small packet
> performance (eg the TCP_RR stuff I posted recently) being rather
> worse with TSO enabled than with it disabled?

That, like any such thing shown by the batching changes, is a bug
to fix.
