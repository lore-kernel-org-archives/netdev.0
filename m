From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] glibc: Terminate process on invalid netlink response
 from kernel [BZ #12926]
Date: Tue, 03 Nov 2015 11:20:14 -0500 (EST)
Message-ID: <20151103.112014.530902170645245377.davem@davemloft.net>
References: <562A9391.1040806@redhat.com>
	<1446558492.1880442.427793993.78B20B4F@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fweimer@redhat.com, libc-alpha@sourceware.org, hannes@redhat.com,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbbKCQUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:20:22 -0500
In-Reply-To: <1446558492.1880442.427793993.78B20B4F@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 03 Nov 2015 14:48:12 +0100

> David, would such code still be accepted?

I would rather see the netlink interface become more usable, so my
answer is no.
