From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Tue, 08 Oct 2013 15:23:49 -0400 (EDT)
Message-ID: <20131008.152349.729447337097758010.davem@davemloft.net>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948Ab3JHTXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 15:23:50 -0400
In-Reply-To: <1380854061-30091-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Fri,  4 Oct 2013 11:34:21 +0900

> ip link has ability to show extra information of net work device if
> kernel provides sunh information. With this patch veth driver can
> provide its peer ifindex information to ip command via netlink
> interface.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Applied to net-next, thank you.
