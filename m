From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 11/12] IB/mlx5: Add flow steering utilities
Date: Thu, 07 Jan 2016 16:36:35 -0500 (EST)
Message-ID: <20160107.163635.666507309041930170.davem@davemloft.net>
References: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
	<1452117151-28572-12-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dledford@redhat.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com, talal@mellanox.com, majd@mellanox.com,
	matanb@mellanox.com, maorg@mellanox.com, monis@mellanox.com,
	saeedm@dev.mellanox.co.il
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbcAGVgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 16:36:38 -0500
In-Reply-To: <1452117151-28572-12-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch should cause compiler warnings because the static functions
are not used until patch #12.
