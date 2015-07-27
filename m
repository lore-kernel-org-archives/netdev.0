From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net/mlx4_en: Hardware accelerated 802.1ad
Date: Mon, 27 Jul 2015 15:00:53 -0700 (PDT)
Message-ID: <20150727.150053.102391071393638884.davem@davemloft.net>
References: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadarh@mellanox.com, ogerlitz@mellanox.com,
	talal@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbbG0WAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 18:00:54 -0400
In-Reply-To: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 27 Jul 2015 14:46:30 +0300

> This patchset by Hadar introduces support in Hardware accelerated 802.1ad, for
> ConnectX-3pro NIC's.  In order to support existing deployment, and due to some
> hardware limitations, the feature is disabled by default, and needed to be
> enabled using a private flag in ethtool. Ofcourse user can enable the private
> flag only if hardware has support.
> After being enabled, the standard ethtool -k/-K can be used.
> 
> Patchset was applied and tested over commit 71790a2 ("hv_netvsc: Add structs
> and handlers for VF messages")

Series applied, thanks.
