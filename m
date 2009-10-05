From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/21] drivers/net/tlan: use pr_<level> and add
 pr_fmt(fmt)
Date: Mon, 05 Oct 2009 00:12:33 -0700 (PDT)
Message-ID: <20091005.001233.174570234.davem@davemloft.net>
References: <cover.1254701151.git.joe@perches.com>
	<cover.1254701151.git.joe@perches.com>
	<d4468c1b062875f4b88ba94f4631232ecff9c27b.1254701151.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chessman@tux.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54627
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758006AbZJEHMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:12:38 -0400
In-Reply-To: <d4468c1b062875f4b88ba94f4631232ecff9c27b.1254701151.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun,  4 Oct 2009 17:53:47 -0700

> Added #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Converted printk(KERN_<level> to pr_<level>(
> Removed "TLAN: " prefixes
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next-2.6
