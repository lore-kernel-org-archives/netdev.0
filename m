From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel
 module
Date: Thu, 26 Feb 2009 23:34:56 -0800 (PST)
Message-ID: <20090226.233456.216465960.davem@davemloft.net>
References: <7418.1235679608@death.nxdomain.ibm.com>
	<49A70245.9010405@hp.com>
	<f73f7ab80902262325q2779f3f5y4870bc30a062971d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, fubar@us.ibm.com, brian.haley@hp.com,
	arvidjaar@mail.ru, chuck.lever@oracle.com, tytso@mit.edu,
	Valdis.Kletnieks@vt.edu, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: kyle@moffetthome.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753034AbZB0HfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 02:35:13 -0500
In-Reply-To: <f73f7ab80902262325q2779f3f5y4870bc30a062971d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle Moffett <kyle@moffetthome.net>
Date: Fri, 27 Feb 2009 02:25:54 -0500

> I feel extremely nervous about people discussing disabling IPv6 going
> forward.  Current estimates are that the first RIRs will begin to
> exhaust their address spaces (after IANA's address space is exhausted)
> early in 2011.  If you consider that any change probably won't be in a
> released kernel until June or so, there would be all of 18 months left
> until IPv6 is *required* to contact some hosts on the internet.

Dear Chicken Little,

Please take this elsewhere, you're just distracting from the
discussion, and we don't have time for that.

The fact is that people want to disable ipv6, full stop, for one
reason or another.  And all of your talk about firewalling solutions
and "the sky is falling" ipv4 address depletion talk is just ignoreing
reality.
