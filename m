From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw
 addresses
Date: Tue, 26 Feb 2013 15:48:54 -0500 (EST)
Message-ID: <20130226.154854.1170494342255659798.davem@davemloft.net>
References: <1361907862-13009-1-git-send-email-vyasevic@redhat.com>
	<20130226.150309.1215210522427869530.davem@davemloft.net>
	<512D1A01.9020301@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759796Ab3BZUs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 15:48:57 -0500
In-Reply-To: <512D1A01.9020301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 26 Feb 2013 15:24:33 -0500

> For what I was trying to do ioctl() was a really easy way out for both
> kernel and user space implementation, so I gave is shot.

Look at it this way, you were going to have to add these config values
to the rtnetlink LINK dumps anyways. :-)
