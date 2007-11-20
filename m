From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/4] include - Convert IP4 address class
 macros to inline functions
Date: Mon, 19 Nov 2007 22:18:35 -0800 (PST)
Message-ID: <20071119.221835.265154518.davem@davemloft.net>
References: <OF456A1240.FCBC428E-ON88257393.005C5D94-88257393.005CA64F@us.ibm.com>
	<20071119.214655.247082473.davem@davemloft.net>
	<1195538398.4675.86.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, jmorris@namei.org, kaber@coreworks.de,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36197
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751555AbXKTGSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:18:36 -0500
In-Reply-To: <1195538398.4675.86.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 19 Nov 2007 21:59:58 -0800

> > I'm dropping these patches for now.
> 
> Is the use of "is_ip4_<level>" not "ipv4_is_<level>"
> your reason to drop the patches?

Yes.

