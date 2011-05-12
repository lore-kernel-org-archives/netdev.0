From: Rafael Aquini <aquini@linux.com>
Subject: Re: [PATCH net-next-2.6] net/bonding: adjust codingstyle for bond_3ad
 files
Date: Wed, 11 May 2011 21:18:59 -0300
Message-ID: <20110512001858.GA2435@x61.tchesoft.com>
References: <20110511225208.GA18851@x61.tchesoft.com>
 <20110512015237.32d6d92b@absol.kitzblitz>
Reply-To: aquini@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Joe Perches <joe@perches.com>,
	kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Nicolas Kaiser <nikai@nikai.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46369 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab1ELAWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 20:22:38 -0400
Content-Disposition: inline
In-Reply-To: <20110512015237.32d6d92b@absol.kitzblitz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy Nicolas,

On Thu, May 12, 2011 at 01:52:37AM +0200, Nicolas Kaiser wrote:
> > -// ================= AD Exported functions to the main bonding code ==================
> > -void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
> > +// ============= AD Exported functions to the main bonding code ============ */
>    ^^
>    /*

My bad, sorry. I'll be re-posting soon.

Thanks!
-- 
Rafael Aquini <aquini@linux.com>
