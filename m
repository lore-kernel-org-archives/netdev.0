From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add missing kernel-doc for netdev ptype lists
Date: Mon, 21 Mar 2016 22:58:12 -0400 (EDT)
Message-ID: <20160321.225812.1337273474715897839.davem@davemloft.net>
References: <56F0612E.20607@osg.samsung.com>
	<1458594508-14545-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luisbg@osg.samsung.com,
	noureddine@arista.com
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbcCVC6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 22:58:14 -0400
In-Reply-To: <1458594508-14545-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon, 21 Mar 2016 14:08:28 -0700

> .//include/linux/netdevice.h:1826: warning: No description found for parameter 'ptype_all'
> .//include/linux/netdevice.h:1826: warning: No description found for parameter 'ptype_specific'
> 
> Introduced by commit 7866a621043f ("dev: add per net_device packet type
> chains")
> 
> Cc: Salam Noureddine <noureddine@arista.com>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Applied.
