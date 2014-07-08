From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net 0/2] xen-netfront: multi-queue related locking
 fixes
Date: Tue, 08 Jul 2014 11:21:40 -0700 (PDT)
Message-ID: <20140708.112140.46777216054440483.davem@davemloft.net>
References: <1404313755-27349-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbaGHSVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 14:21:44 -0400
In-Reply-To: <1404313755-27349-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 2 Jul 2014 16:09:13 +0100

> Two fixes to the per-queue locking bugs in xen-netfront that were
> introduced in 3.16-rc1 with the multi-queue support.

Series applied, thanks.
