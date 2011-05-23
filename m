From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/3] rtnetlink: ignore NETDEV_RELEASE and NETDEV_JOIN
 event
Date: Sun, 22 May 2011 21:03:19 -0400 (EDT)
Message-ID: <20110522.210319.343081921142686223.davem@davemloft.net>
References: <1305877152-30970-1-git-send-email-amwang@redhat.com>
	<1305882392-21241-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab1EWBDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:03:22 -0400
In-Reply-To: <1305882392-21241-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 20 May 2011 17:06:32 +0800

> These two events are not expected to be caught by userspace.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied.
