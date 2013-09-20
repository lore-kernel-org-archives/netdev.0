From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: ethernet: eth.c: removed checkpatch warnings
 and errors
Date: Fri, 20 Sep 2013 14:42:34 -0400 (EDT)
Message-ID: <20130920.144234.1253837765082596306.davem@davemloft.net>
References: <523b2124.645d440a.1c55.0f75@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akong@redhat.com, stefanha@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: avi.kp.137@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355Ab3ITSmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:42:36 -0400
In-Reply-To: <523b2124.645d440a.1c55.0f75@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: avi.kp.137@gmail.com
Date: Thu, 19 Sep 2013 21:36:50 +0530

> From: Avinash Kumar <avi.kp.137@gmail.com>
> 
> removed these checkpatch.pl warnings:
> net/ethernet/eth.c:61: WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>
> net/ethernet/eth.c:136: WARNING: Prefer netdev_dbg(netdev, ... then dev_dbg(dev, ... then pr_debug(...  to printk(KERN_DEBUG ...
> net/ethernet/eth.c:181: ERROR: space prohibited before that close parenthesis ')'
> 
> Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>

Applied.
