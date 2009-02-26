From: David Miller <davem@davemloft.net>
Subject: Re: unloading the ipv6 module
Date: Thu, 26 Feb 2009 05:24:11 -0800 (PST)
Message-ID: <20090226.052411.77955912.davem@davemloft.net>
References: <49A69784.6070204@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752499AbZBZNY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:24:29 -0500
In-Reply-To: <49A69784.6070204@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Thu, 26 Feb 2009 14:22:12 +0100

> I saw in net/ipv6/Kconfig a comment saying
> "IPv6 as module will cause a CRASH if you try to unload it".
> 
> If I refer to this comment, that means unloading of ipv6 is not
> supported (which makes sense), will it be one day supported?

It's very unlikely to be supported any time soon.

Maybe "one day" as in 5 years from now at the earliest.

It's just such an enormous set of problems to solve to make it work,
and there are so many more urgent issues to work on.
