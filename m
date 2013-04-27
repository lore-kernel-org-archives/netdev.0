From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: use IANA assigned port
Date: Sat, 27 Apr 2013 03:43:20 -0400 (EDT)
Message-ID: <20130427.034320.244588324045535017.davem@davemloft.net>
References: <20130427015129.GJ8882@sequoia.sous-sol.org>
	<20130426.232232.688463657786151100.davem@davemloft.net>
	<CAOaVG14yv=TixikAkrjEOTBznoC6YDqm1vb4ByZ32bgXM3Q7xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kduda@aristanetworks.com, netdev@vger.kernel.org,
	chrisw@sous-sol.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab3D0HnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 03:43:23 -0400
In-Reply-To: <CAOaVG14yv=TixikAkrjEOTBznoC6YDqm1vb4ByZ32bgXM3Q7xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 26 Apr 2013 21:53:59 -0700

> The port should be a property anyway.
> That way the value is easier to control. And we can do the transistion
> there.

Works for me.
