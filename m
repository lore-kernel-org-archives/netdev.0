From: David Miller <davem@davemloft.net>
Subject: Re: E100 RX ring buffers continued...
Date: Sun, 23 Aug 2009 19:03:05 -0700 (PDT)
Message-ID: <20090823.190305.68618999.davem@davemloft.net>
References: <1288246454.81251051629969.JavaMail.root@mail.holmansrus.com>
	<m3k50utg5q.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: walt@holmansrus.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50089
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751171AbZHXCCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 22:02:52 -0400
In-Reply-To: <m3k50utg5q.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sun, 23 Aug 2009 22:43:29 +0200

> David, I think it's safe to apply this.

Yep, I've applied this to net-2.6, thanks!

> Probably to "stable" series, too.

That would depend upon applying your original patch to -stable,
which I had no intentions of doing.
