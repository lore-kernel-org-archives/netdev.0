From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/21] drivers/net/bonding/: : use pr_fmt
Date: Mon, 05 Oct 2009 00:12:26 -0700 (PDT)
Message-ID: <20091005.001226.120933767.davem@davemloft.net>
References: <cover.1254701151.git.joe@perches.com>
	<cover.1254701151.git.joe@perches.com>
	<ec7e258261ac67ba496f96d04c270cf89fc24deb.1254701151.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755538AbZJEHMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:12:31 -0400
In-Reply-To: <ec7e258261ac67ba496f96d04c270cf89fc24deb.1254701151.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun,  4 Oct 2009 17:53:46 -0700

> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Remove DRV_NAME from pr_<level>s
> Consolidate long format strings
> Remove some extra tab indents
> Remove some unnecessary ()s from pr_<level>s arguments
> Align pr_<level> arguments
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next-2.6
