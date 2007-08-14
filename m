From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/6] e1000e: remove namespace collisions with e1000
Date: Tue, 14 Aug 2007 14:22:15 -0700
Message-ID: <46C21D07.6060108@intel.com>
References: <20070810200038.21509.77815.stgit@localhost.localdomain>	<20070810200047.21509.46779.stgit@localhost.localdomain> <46C139F6.2040007@garzik.org> <46C1DB49.1080601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, andi@firstfloor.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39097 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754495AbXHNVWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 17:22:44 -0400
In-Reply-To: <46C1DB49.1080601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>> if you grep around this effort was already started using the 'e1e_' 
>> prefix.  I like the shorter prefix, but your call ultimately.  Either 
>> way, make sure to make the driver consistent there too.
> 
> should it then be consistent with the overall driver name too? 
> certainly calling things e1e or e1ke  or heck, even elke if one wanted 
> to be a triffle playful would certainly help distinguish this driver 
> from its grandfather.

I think we are passed the time for the name-a-driver raffle now. We've informed 
a lot of people that the name will be "e1000e", so I definately prefer using 
this internally as well.

As for the e1000_get_speed_and_duplex_fiber_serdes long names, those are an 
eyesore to me as well...

Auke
