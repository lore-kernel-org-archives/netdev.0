From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4:Remove two memleak reports by
 kmemeleak_not_leak.
Date: Wed, 18 Apr 2012 00:22:46 -0400 (EDT)
Message-ID: <20120418.002246.1732341186957682813.davem@davemloft.net>
References: <201204171333149372727@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: majianpeng@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab2DREWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 00:22:49 -0400
In-Reply-To: <201204171333149372727@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "majianpeng" <majianpeng@gmail.com>
Date: Tue, 17 Apr 2012 13:33:31 +0800

>>From fe9ae7e12cc7bdc56705eb504facb71aa86dfe65 Mon Sep 17 00:00:00 2001
> From: majianpeng <majianpeng@gmail.com>
> Date: Tue, 17 Apr 2012 13:29:55 +0800
> Subject: [PATCH] net/ipv4:Remove two memleak reports by kmemeleak_not_leak.
> 
> 
> Signed-off-by: majianpeng <majianpeng@gmail.com>

I've applied both of your patches, but you are EXTREMELY careless
with your commit log messages and subject lines.

In this patch, and the net/core one, you misspell "kmemleak_not_leak"

In the net/core patch, you failed to separate "by" and "kmemleak_not_leak"
with a space in the Subject line.

Furthermore, it is extraneous to include the same From:, Date:, and
Subject: fields in the body of your email.  They are just fine in
your normal email headers.

Thanks.
