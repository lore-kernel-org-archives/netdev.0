From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] xen-netfront: use new
 skb_checksum_setup function
Date: Mon, 13 Jan 2014 11:27:20 -0800 (PST)
Message-ID: <20140113.112720.2236966361404094251.davem@davemloft.net>
References: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
	<1389261768-30606-4-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbaAMT1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:27:21 -0500
In-Reply-To: <1389261768-30606-4-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Thu, 9 Jan 2014 10:02:48 +0000

> Use skb_checksum_setup to set up partial checksum offsets rather
> then a private implementation.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

This patch really needs review by a netfront expert before I can apply
this series.

Thanks.
