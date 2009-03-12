From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] be2net: header files
Date: Wed, 11 Mar 2009 23:33:32 -0700 (PDT)
Message-ID: <20090311.233332.71532600.davem@davemloft.net>
References: <1236687290.21691.46.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, kaber@trash.net,
	subbus@serverengines.com
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751718AbZCLGdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 02:33:46 -0400
In-Reply-To: <1236687290.21691.46.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 10 Mar 2009 17:44:50 +0530

> Hi, This is a re-post of the be2net driver incorporating fixes for
> review comments received:
> 
> - sparse warnings, especially __iomem type checking
> - an earlier comment by Patrick McHardy to disable vlan hardware
> filtering when the number of configured vlans exceeds number of
> supported vlans.
> 
> The code is also available in a single patch file at
> ftp://ftp.serverengines.com/be2net.patch (anonymous)
> 
> The patches are against the Linus git tree.

I've added your driver to the tree, thank you.
