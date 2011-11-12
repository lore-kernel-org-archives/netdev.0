From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next V7] net: introduce ethernet teaming device
Date: Sat, 12 Nov 2011 00:45:55 -0500 (EST)
Message-ID: <20111112.004555.1043819970109229358.davem@davemloft.net>
References: <20111111170509.581c4ca2@asterix.rh>
	<20111111175845.10c82c3c@asterix.rh>
	<20111112001459.GA2448@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, benjamin.poirier@gmail.com, jzupka@redhat.com,
	ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1KLFsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 00:48:50 -0500
In-Reply-To: <20111112001459.GA2448@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 12 Nov 2011 01:15:00 +0100

> Yes, this should be checked. I missed that. I would like to address this
> as follow up patch because I'm sure it's not the last bug in team (I
> would be sending Vx of the patch for long time :( )

No, Jiri.  Known bugs with obvious fixes get fixed first.

You see it as an endless process, but rather the code just isn't ready
yet if people can still find easy to diagnose and fix flaws so
quickly.
