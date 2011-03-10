From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 29252] New: IPv6 doesn't work in a kvm guest.
Date: Wed, 09 Mar 2011 19:20:12 -0800 (PST)
Message-ID: <20110309.192012.193710171.davem@davemloft.net>
References: <bug-29252-10286@https.bugzilla.kernel.org/>
	<20110217142517.b9919481.akpm@linux-foundation.org>
	<20110309.155818.212679516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, slash@ac.auone-net.jp,
	ernstp@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48772
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751675Ab1CJDTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 22:19:34 -0500
In-Reply-To: <20110309.155818.212679516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 09 Mar 2011 15:58:18 -0800 (PST)

> Ok, the following should address both bugs, #29252 and #30462, please
> give it some testing.
> 
> --------------------
> ipv6: Don't create clones of nonexthop routes forever.

Nevermind, this patch has problems, I'm still debugging and trying to
come up with a proper fix.

Thanks in advance for your patience.
