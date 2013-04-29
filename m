From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Remove unneeded
 ovs_netdev_get_ifindex()
Date: Mon, 29 Apr 2013 14:08:47 -0400 (EDT)
Message-ID: <20130429.140847.580364047961406628.davem@davemloft.net>
References: <a59b1675cc29cd2897bdf1fb6ae34bfd0971fbb7.1366980015.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab3D2SIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:08:49 -0400
In-Reply-To: <a59b1675cc29cd2897bdf1fb6ae34bfd0971fbb7.1366980015.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 26 Apr 2013 14:40:55 +0200

> The only user is get_dpifindex(), no need to redirect via the port
> operations.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Please follow-up with the stylistic feedback given to you if you
haven't already, thanks.
