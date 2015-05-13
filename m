From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Remove remaining remnants of pm_qos from
 netdevice.h
Date: Tue, 12 May 2015 23:22:37 -0400 (EDT)
Message-ID: <20150512.232237.904920326552005422.davem@davemloft.net>
References: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
	<1431445020-25235-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934418AbbEMDWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:22:38 -0400
In-Reply-To: <1431445020-25235-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 12 May 2015 09:37:00 -0600

> Commit e2c6544829f removed pm_qos from struct net_device but left the
> comment and header file. Remove those.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
