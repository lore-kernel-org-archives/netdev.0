From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove remaining remnants of pm_qos from
 netdevice.h
Date: Mon, 11 May 2015 13:11:06 -0400 (EDT)
Message-ID: <20150511.131106.1902675173206646881.davem@davemloft.net>
References: <1431210103-18683-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbEKRLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:11:10 -0400
In-Reply-To: <1431210103-18683-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Sat,  9 May 2015 16:21:43 -0600

> Commit e2c6544829f removed pm_qos from struct net_device but left the
> comment above header file. Remove those.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied, thanks David.
