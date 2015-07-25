From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: support ndo_get_phys_port_id()
Date: Fri, 24 Jul 2015 22:41:37 -0700 (PDT)
Message-ID: <20150724.224137.68785858473625935.davem@davemloft.net>
References: <1437543912-3096-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbbGYF2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 01:28:37 -0400
In-Reply-To: <1437543912-3096-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Date: Wed, 22 Jul 2015 11:15:12 +0530

> From: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
> 
> Add be_get_phys_port_id() function to report physical port id. The port id
> should be unique across different be2net devices in the system. We use the
> chip serial number along with the physical port number for this.
> 
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>

Applied, thanks.
