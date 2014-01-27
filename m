From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_PACKET: Add documentation for queue mapping fanout
 mode
Date: Mon, 27 Jan 2014 12:57:54 -0800 (PST)
Message-ID: <20140127.125754.1285784322055554689.davem@davemloft.net>
References: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428AbaA0U5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 15:57:54 -0500
In-Reply-To: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 27 Jan 2014 11:43:04 -0500

> Recently I added a new AF_PACKET fanout operation mode in commit
> 2d36097, but I forgot to document it.  Add PACKET_FANOUT_QM as an available mode
> in the af_packet documentation.  Applies to net-next.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
