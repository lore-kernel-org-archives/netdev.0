From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] ixgbe: remove rx_hdr_split debug
 counter for non-debug configurations
Date: Wed, 27 May 2009 13:52:11 -0700 (PDT)
Message-ID: <20090527.135211.44614815.davem@davemloft.net>
References: <20090527005445.28535.9069.stgit@localhost.localdomain>
	<20090526.203810.50281143.davem@davemloft.net>
	<1243423017.16597.143.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40146
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752564AbZE0UwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 16:52:12 -0400
In-Reply-To: <1243423017.16597.143.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 May 2009 12:16:57 +0100

> If rx_hdr_split means the same thing at Intel as it does here, it's a
> hardware feature Microsoft wants for use in Hyper-V and it won't be
> enabled under Linux.

Nobody explains anything, so it could or it could not be, who knows.
:-)
