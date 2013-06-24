From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx_en: Timestamping is not supported in slave
 mode
Date: Mon, 24 Jun 2013 00:03:18 -0700 (PDT)
Message-ID: <20130624.000318.2195130036065711899.davem@davemloft.net>
References: <1371729490-10491-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab3FXHDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:03:19 -0400
In-Reply-To: <1371729490-10491-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 20 Jun 2013 14:58:10 +0300

> Old hypervisors don't mask out timestamp capability for slave. Till slave
> support will be added, need to disable capability by slave.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied.
