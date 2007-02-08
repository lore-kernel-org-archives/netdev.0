From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [RESEND] X.25: Add call forwarding
Date: Thu, 08 Feb 2007 13:34:13 -0800 (PST)
Message-ID: <20070208.133413.130238005.davem@davemloft.net>
References: <1167881822.5124.88.camel@localhost>
	<20070104102702.30630a9d@localhost.localdomain>
	<1170890065.5189.39.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, eis@baty.hanse.de,
	linux-x25@vger.kernel.org, netdev@vger.kernel.org
To: ahendry@tusc.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42720
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423429AbXBHVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:34:14 -0500
In-Reply-To: <1170890065.5189.39.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ahendry <ahendry@tusc.com.au>
Date: Thu, 08 Feb 2007 10:14:25 +1100

> Adds call forwarding to X.25, allowing it to operate like an X.25 router.
> Useful if one needs to manipulate X.25 traffic with tools like tc.
> This is an update/cleanup based off a patch submitted by Daniel Ferenci a few years ago.
> 
> Thanks Alan for the feedback.
> Added the null check to the clones.
> Moved the skb_clone's into the forwarding functions.
> 
> Worked ok with Cisco XoT, linux X.25 back to back, and some old NTUs/PADs.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied, thanks.
