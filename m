From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: updated phy errata
Date: Fri, 04 Sep 2009 15:00:15 -0700 (PDT)
Message-ID: <20090904.150015.247320928.davem@davemloft.net>
References: <4A9C57F5.10800@nvidia.com>
	<20090902.232201.248326790.davem@davemloft.net>
	<4AA11CE7.7050400@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, akpm@osdl.org, netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934335AbZIDWAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 18:00:01 -0400
In-Reply-To: <4AA11CE7.7050400@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 04 Sep 2009 09:57:59 -0400

> Unfortunately, the phy vendors don't want us exposing the meaning of
> their non-standard bits.

So when you go away and some other developer tries to debug a problem
in this area, then what happens?  Do they just guess what those bits
mean?

Sorry, this sort of situation is unacceptable in this modern day and
age.  You'll need to work this out before I'm willing to take the
patch.
