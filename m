From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 12:07:25 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903C08245@orsmsx414.amr.corp.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>	<1191886845.4373.138.camel@localhost>	<470AD5D7.1070000@garzik.org> <20071008.184126.124062865.davem@davemloft.net> <470AE373.9020207@garzik.org> <D5C1322C3E673F459512FB59E0DDC32903C0821A@orsmsx414.amr.corp.intel.com> <470BD0B7.4070607@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <hadi@cyberus.ca>,
	<krkumar2@in.ibm.com>, <johnpol@2ka.mipt.ru>,
	<herbert@gondor.apana.org.au>, <kaber@trash.net>,
	<shemminger@linux-foundation.org>, <jagana@us.ibm.com>,
	<Robert.Olsson@data.slu.se>, <rick.jones2@hp.com>,
	<xma@us.ibm.com>, <gaagaan@gmail.com>, <netdev@vger.kernel.org>,
	<rdreier@cisco.com>, <mcarlson@broadcom.com>, <mchan@broadcom.com>,
	<general@lists.openfabrics.org>, <tgraf@suug.ch>,
	<randy.dunlap@oracle.com>, <sri@us.ibm.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17344 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496AbXJITHl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 15:07:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <470BD0B7.4070607@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> A misunderstanding, I think.
> 
> To my brain, DaveM's item #2 seemed to assume/require the NIC 
> hardware to balance fairly across hw TX rings, which seemed 
> to preclude the
> 8139cp/tg3 style of strict-prio hardware.  That's what I was 
> responding to.
> 
> As long as there is some modular way to fit 8139cp/tg3 style 
> multi-TX into our universe, I'm happy :)

Ah hah.  Yes, a misunderstanding on my part.  Thanks for the
clarification.  Methinks more caffeine is required for today...

-PJ
