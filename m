From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSOframe   size
Date: Thu, 28 Feb 2008 09:10:37 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290498D2EE@orsmsx414.amr.corp.intel.com>
References: <20080227172606.4446.97153.stgit@localhost.localdomain> <20080228080746.GA7067@ff.dom.local> <20080228082919.GB7067@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <stephen.hemminger@vyatta.com>,
	<netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20675 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671AbYB1RKo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 12:10:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080228082919.GB7067@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ...And since it looks like not very often used - maybe it 
> could be placed a bit lower?
> 
> Jarek P.

Yes, I can move it.  I just grouped it with the other GSO/TSO elements
in the struct.  I'll take a closer look and see if I can place it
elsewhere for better efficiency.  I'll send change along with the other
changes from your other feedback.

Thanks,

-PJ Waskiewicz
