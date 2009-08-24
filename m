From: David Miller <davem@davemloft.net>
Subject: Re: E100 RX ring buffers continued...
Date: Mon, 24 Aug 2009 13:10:48 -0700 (PDT)
Message-ID: <20090824.131048.208330430.davem@davemloft.net>
References: <m3k50utg5q.fsf@intrepid.localdomain>
	<20090823.190305.68618999.davem@davemloft.net>
	<m3bpm5v65e.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: walt@holmansrus.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751078AbZHXUKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 16:10:35 -0400
In-Reply-To: <m3bpm5v65e.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 24 Aug 2009 12:49:01 +0200

> David Miller <davem@davemloft.net> writes:
> 
>>> Probably to "stable" series, too.
>>
>> That would depend upon applying your original patch to -stable,
>> which I had no intentions of doing.
> 
> Still you sent it for both 2.6.27 and .30 anyway :-)

Did I?  Aha, then I indeed have to send your fix :-)
