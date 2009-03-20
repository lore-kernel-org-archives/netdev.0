From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: sunvnet netdev ops conversion...
Date: Fri, 20 Mar 2009 15:54:21 -0700 (PDT)
Message-ID: <20090320.155421.72000678.davem@davemloft.net>
References: <87prgcju7v.fsf@nemi.mork.no>
	<20090320141949.GA1031@psychotron.englab.brq.redhat.com>
	<20090320091618.2604ad53@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, bjorn@mork.no, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751731AbZCTWye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 18:54:34 -0400
In-Reply-To: <20090320091618.2604ad53@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 09:16:18 -0700

> I intend to get all drivers in x86 allmodconfig converted, then
> change expose the COMPAT_NETDEV_OPS as a config option (which is how
> I test).

If it were not for the randconfig maniacs I would say that I think you
should expose it somehow now.

Turning it off is how I personally do conversions in fact.
