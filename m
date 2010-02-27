From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] bridge: Add multicast_router sysfs entries
Date: Sat, 27 Feb 2010 03:29:15 -0800 (PST)
Message-ID: <20100227.032915.98669174.davem@davemloft.net>
References: <20100226153410.GA26419@gondor.apana.org.au>
	<E1Nl2Dj-0006wU-LU@gondolin.me.apana.org.au>
	<20100226164211.1a02a31b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58162
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965891Ab0B0L25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 06:28:57 -0500
In-Reply-To: <20100226164211.1a02a31b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 26 Feb 2010 16:42:11 -0800

> I like the functionality, but don't like users whacking on sysfs
> directly. Could you send patches to integrate a user API into
> bridge-utils; the utils are at: 
>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git

Sounds reasonable to me.

Herbert, please do this after we've resolved the issues in your
patch set and integrated it.

Thanks!
