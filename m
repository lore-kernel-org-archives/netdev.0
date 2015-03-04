From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 0/2 net] xen-netback: fix ethtool stats and memory
Date: Wed, 04 Mar 2015 00:22:14 -0500 (EST)
Message-ID: <20150304.002214.460233220632683972.davem@davemloft.net>
References: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbCDFWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:22:16 -0500
In-Reply-To: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 3 Mar 2015 16:26:09 +0000

> A couple of bug fixes for netback:
> - make ethool stats to report the correct values.
> - don't leak 1 MiB every time a VIF is destroyed.

Please fix up the minor commit message issues in patch #2
and resubmit this series, thanks.
