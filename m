From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Tue, 03 Aug 2010 19:33:48 +0200
Message-ID: <1280856828.3266.839.camel@pohly-mobl1.ikn.intel.com>
References: <4C529EFB.4090601@hartkopp.net>
	 <20100801.010337.68133932.davem@davemloft.net>
	 <4C555168.3090800@hartkopp.net>
	 <20100803.003056.216763358.davem@davemloft.net>
	 <4C583447.8010004@hartkopp.net>
	 <1280852081.3266.834.camel@pohly-mobl1.ikn.intel.com>
	 <4C584DB2.8020406@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	"matthias.fuchs@esd.eu" <matthias.fuchs@esd.eu>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64412 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753482Ab0HCRdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 13:33:53 -0400
In-Reply-To: <4C584DB2.8020406@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-03 at 10:11 -0700, Oliver Hartkopp wrote:
> > I'm fine with using a simple u8. I'm not sure where I picked up the
> > union thing, it's not something that I usually do in my own code.
> > 
> 
> :-)
> 
> Im currently busy until next week, would you like to provide a patch?

Sorry, I have to pass. I'm busy elsewhere myself. MeeGo and
SyncEvolution plus real life consume all of my time nowadays.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.


