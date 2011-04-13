From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 RFC PATCH v2 00/13] ethtool: allow custom
 interval for
Date: Wed, 13 Apr 2011 13:25:47 -0700 (PDT)
Message-ID: <20110413.132547.245403553.davem@davemloft.net>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
	<1302725464.2873.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50280
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757552Ab1DMU0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 16:26:23 -0400
In-Reply-To: <1302725464.2873.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 13 Apr 2011 21:11:04 +0100

> On Wed, 2011-04-13 at 12:58 -0700, Bruce Allan wrote:
>> physical identification
>> 
>> The following series changes the recently added ethtool set_phys_id
>> functions to allow drivers to provide a frequency at which to cycle
>> through an on/off identifier via software if/when the capability is
>> not provided by hardware.
> [...]
> 
> The first patch leaves all the drivers broken temporarily.  Since the
> change in each driver is trivial, I think you can squash this all into
> one patch.

Agreed.
