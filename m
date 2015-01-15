From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] be2net: Allow GRE to work concurrently while a
 VxLAN tunnel is configured
Date: Thu, 15 Jan 2015 01:55:35 -0500 (EST)
Message-ID: <20150115.015535.1738053583499872779.davem@davemloft.net>
References: <1421318323-2547-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbbAOGzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 01:55:36 -0500
In-Reply-To: <1421318323-2547-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Date: Thu, 15 Jan 2015 16:08:43 +0530

> Other tunnels like GRE break while VxLAN offloads are enabled in Skyhawk-R. To
> avoid this, we should restrict offload features on a per-packet basis in such
> conditions.
> 
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>

Applied, thanks.
