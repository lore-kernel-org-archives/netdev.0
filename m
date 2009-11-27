From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] netdevice: provide common routine for macvlan and
 vlan	operstate management
Date: Fri, 27 Nov 2009 23:30:41 +0100
Message-ID: <4B105311.1020005@trash.net>
References: <20091127220717.14078.6058.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55844 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbZK0Wah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 17:30:37 -0500
In-Reply-To: <20091127220717.14078.6058.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Mullaney wrote:
> Applies to net-2.6.git/master:0135ae0b9)
> 
> Provide common routine for the transition of operational state for a leaf
> device during a root device transition. This updates a previous patch in
> my venet macvlan series and fixes the problems that Arnd pointed out.
> 
> Is submitting this applied to net-next a more better approach?

Yes, please base this patch on net-next.

> Signed-off-by: Patrick Mullaney <pmullaney@novell.com>

Acked-by: Patrick McHardy <kaber@trash.net>
