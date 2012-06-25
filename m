From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen : Error return off by one for XG port.
Date: Mon, 25 Jun 2012 15:27:28 -0700 (PDT)
Message-ID: <20120625.152728.927283949220930736.davem@davemloft.net>
References: <1340189578-18308-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757295Ab2FYW13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 18:27:29 -0400
In-Reply-To: <1340189578-18308-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: santosh nayak <santoshprasadnayak@gmail.com>
Date: Wed, 20 Jun 2012 16:22:58 +0530

> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> There are  NETXEN_NIU_MAX_XG_PORTS ports.
> Port indexing starts from zero.
> Hence we should also return error for  'port == NETXEN_NIU_MAX_XG_PORTS'.
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>

Applied.
