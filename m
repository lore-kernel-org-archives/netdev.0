From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 28/39] natsemi: stop using
 net_device.{base_addr, irq}.
Date: Tue, 10 Apr 2012 20:42:02 -0400 (EDT)
Message-ID: <20120410.204202.923592889066244236.davem@davemloft.net>
References: <CAAAKZwvRvc=6qwainJAkHCUEme+PsFY-s0PWxj9tYXwSmBcYJA@mail.gmail.com>
	<20120410.200212.1031414009653598743.davem@davemloft.net>
	<CAAAKZwt9TUdDS6-pQ_aDAMxJ+MRTNnHxC0Fuajm_WsqjUED6wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951Ab2DKAnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:43:09 -0400
In-Reply-To: <CAAAKZwt9TUdDS6-pQ_aDAMxJ+MRTNnHxC0Fuajm_WsqjUED6wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Hockin <thockin@hockin.org>
Date: Tue, 10 Apr 2012 17:19:42 -0700

> I agree.  The patches to this driver have been very few and far
> between, but even those I am largely unable to review any more.
> 
> I'm more than willing to hand it off to someone who can do a better job of it

My inclination was the mark the driver Orphan'd, which represents
the current state of affairs quite accurately.
