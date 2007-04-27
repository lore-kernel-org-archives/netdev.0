From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 27 Apr 2007 11:43:47 -0400
Message-ID: <46321A33.8050103@pobox.com>
References: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com>	 <1177594079.4077.37.camel@localhost>  <4630CBF3.9030202@trash.net> <1177685918.4059.67.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40442 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756006AbXD0Poc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 11:44:32 -0400
In-Reply-To: <1177685918.4059.67.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Heres the way i see it from a user perspective:
> If a NIC has 3 hardware queues; if that NIC supports strict priority
> (i.e the prio qdisc) which we already support, there should be no need
> for the user to really explicitly enable that support. 
> It should be transparent to them - because by configuring a multi queue
> prio qdisc (3 bands/queues default), they are already doing multiqueues.

Agreed.

	Jeff


