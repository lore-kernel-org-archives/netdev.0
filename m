From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 17:20:10 -0700 (PDT)
Message-ID: <20060803.172010.102611616.davem@davemloft.net>
References: <1154647699.3117.26.camel@rh4>
	<20060803.164311.91310742.davem@davemloft.net>
	<20060804000707.GA15342@thunk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41965
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932373AbWHDAUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 20:20:09 -0400
To: tytso@mit.edu
In-Reply-To: <20060804000707.GA15342@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Theodore Tso <tytso@mit.edu>
Date: Thu, 3 Aug 2006 20:07:07 -0400

> Removing the timer-based "ping" might be a good thing to do from the
> point of view of reducing power utilization of laptops (but hey, I
> don't have a tg3 in my laptop, so I won't worry about it a whole lot :-), 

You won't have "ASF" in your laptop tg3. ASF, as the second character
it's acronym implies is for "Servers".
