From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2 - rev2] qdisc_restart - readability changes plus onebug fix.
Date: Mon, 18 Jun 2007 10:51:46 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329030D56EB@orsmsx414.amr.corp.intel.com>
References: <1182142284.6082.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hadi@cyberus.ca>, <herbert@gondor.apana.org.au>, <tgraf@suug.ch>,
	<kaber@trash.net>, <netdev@vger.kernel.org>
To: <kumarkr@linux.vnet.ibm.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30249 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757655AbXFRRwB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 13:52:01 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1182142284.6082.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Krishna Kumar [mailto:kumarkr@linux.vnet.ibm.com] 
> Sent: Sunday, June 17, 2007 9:51 PM
> To: davem@davemloft.net
> Cc: hadi@cyberus.ca; herbert@gondor.apana.org.au; Waskiewicz 
> Jr, Peter P; tgraf@suug.ch; kaber@trash.net; netdev@vger.kernel.org
> Subject: [PATCH 1/2 - rev2] qdisc_restart - readability 
> changes plus onebug fix.
> 
> New changes :
> 
> - Incorporated Peter Waskiewicz's comments.
> - Re-added back one warning message (on driver returning wrong value).

I've run these patches last night and this morning without issue.  I see
no issues with these updated patches from my testing.

Thanks,
-PJ Waskiewicz
