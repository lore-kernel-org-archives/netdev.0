From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: frag: make sure forced eviction removes all
 frags
Date: Fri, 07 Mar 2014 13:09:23 -0500 (EST)
Message-ID: <20140307.130923.896261869884883559.davem@davemloft.net>
References: <1394125601-27685-1-git-send-email-fw@strlen.de>
	<1394127382.27473.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140307095605.1d382db0@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbaCGSJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 13:09:27 -0500
In-Reply-To: <20140307095605.1d382db0@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 7 Mar 2014 09:56:05 +0100

> Thanks for CC'ing me, and adding the "Fixes" tag (but which DaveM forgot
> to pickup in the commit...)

Oops... we should probably ask patchwork to start recognizing it.
