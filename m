From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw
 addresses
Date: Tue, 26 Feb 2013 12:43:22 -0500 (EST)
Message-ID: <20130226.124322.28904104699526114.davem@davemloft.net>
References: <1361897970-1728-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155Ab3BZRnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 12:43:31 -0500
In-Reply-To: <1361897970-1728-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No new ioctls please, extend the netlink interfaces as necessary
instead.

Thanks.
