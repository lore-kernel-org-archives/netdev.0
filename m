From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH,RFC] Marvell Orion SoC ethernet driver
Date: 17 Oct 2007 18:33:23 -0700
Message-ID: <20071018013323.19721.qmail@farnsworth.org>
References: <20071016192806.GD19618@xi.wantstofly.org> <1192570275.14601.10.camel@sakura.staff.proxad.net>
Cc: netdev@vger.kernel.org, tzachi@marvell.com, nico@cam.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:37666 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1760919AbXJRBeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:34:05 -0400
In-Reply-To: <20071018011536.GA3704@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071018011536.GA3704@xi.wantstofly.org> you write:
> Interesting.  After some asking around, it appears that the mv643xx
> ethernet silicon block is indeed very similar to the ethernet silicon
> block found the in Orion ARM SoCs.
> 
> We'll work on getting Orion to use mv643xx_eth.  Thanks for pointing
> this out.

Cool.  I'd be very receptive to any cleanups you might provide for the
mv643xx_eth driver.

-Dale
