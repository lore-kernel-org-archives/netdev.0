From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] openvswitch: Remove unneeded
 ovs_netdev_get_ifindex()
Date: Tue, 30 Apr 2013 00:19:28 -0400 (EDT)
Message-ID: <20130430.001928.1165027745697375853.davem@davemloft.net>
References: <ccb6cc7843629082ac121043a00947a15561f26f.1367276702.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab3D3ETa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 00:19:30 -0400
In-Reply-To: <ccb6cc7843629082ac121043a00947a15561f26f.1367276702.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 30 Apr 2013 01:06:41 +0200

> The only user is get_dpifindex(), no need to redirect via the port
> operations.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> V2 - Fix stylistic issue

Applied, thanks Thomas.
