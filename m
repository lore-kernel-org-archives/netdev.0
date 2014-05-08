From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution function
Date: Thu, 08 May 2014 08:18:22 -0700
Message-ID: <536BA03E.6030109@intel.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com> <1399553434-25617-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32051 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733AbaEHPT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 11:19:58 -0400
In-Reply-To: <1399553434-25617-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2014 05:50 AM, Amir Vadai wrote:
> From: Ido Shamay <idos@mellanox.com>
> 
> This commit exposes an header length compution generic function,
> introduced in some of Intel's Etherent drivers (igb and ixgbe),
> to net public namespace under the name __net_get_headlen,
> where it can be used by other vendors and removes code duplication.
> 
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Thanks for doing this.  It was something I was meaning to do but just
haven't had the time to do it.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
