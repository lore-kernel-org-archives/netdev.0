From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 2/3] bridge: call NETDEV_JOIN notifiers when add a slave
Date: Sun, 22 May 2011 21:03:09 -0400 (EDT)
Message-ID: <20110522.210309.1616713675797770195.davem@davemloft.net>
References: <1305877152-30970-1-git-send-email-amwang@redhat.com>
	<1305877152-30970-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab1EWBDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:03:12 -0400
In-Reply-To: <1305877152-30970-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 20 May 2011 15:39:11 +0800

> In the previous patch I added NETDEV_JOIN, now
> we can notify netconsole when adding a device to a bridge too.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>

Applied.
