From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: md5: using remote adress for md5 lookup in rst
 packet
Date: Sun, 22 Jan 2012 14:25:17 -0500 (EST)
Message-ID: <20120122.142517.1979451909648698972.davem@davemloft.net>
References: <1327098124-19922-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaoclu@gmail.com
To: shawn.lu@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab2AVTZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:25:23 -0500
In-Reply-To: <1327098124-19922-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Lu <shawn.lu@ericsson.com>
Date: Fri, 20 Jan 2012 14:22:04 -0800

> From: shawnlu <shawn.lu@ericsson.com>
> 
> md5 key is added in socket through remote address.
> remote address should be used in finding md5 key when
> sending out reset packet.
> 
> Signed-off-by: shawnlu <shawn.lu@ericsson.com>

Applied.
