From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 0/2 net] xen-netfront: fix resume regressions in
 3.16-rc1
Date: Sat, 21 Jun 2014 16:15:31 -0700 (PDT)
Message-ID: <20140621.161531.1706990015789186131.davem@davemloft.net>
References: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806AbaFUXPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 19:15:35 -0400
In-Reply-To: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 18 Jun 2014 10:47:26 +0100

> The introduction of multi-queue support to xen-netfront in 3.16-rc1,
> broke resume/migration.

Series applied, thanks.
