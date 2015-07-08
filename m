From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] xen-netback: remove duplicated function definition
Date: Wed, 08 Jul 2015 14:13:03 -0700 (PDT)
Message-ID: <20150708.141303.142292387863267691.davem@davemloft.net>
References: <1436143376-18457-1-git-send-email-liang.z.li@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org
To: liang.z.li@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758919AbbGHVNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:13:05 -0400
In-Reply-To: <1436143376-18457-1-git-send-email-liang.z.li@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liang Li <liang.z.li@intel.com>
Date: Mon,  6 Jul 2015 08:42:56 +0800

> There are two duplicated xenvif_zerocopy_callback() definitions.
> Remove one of them.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>

Applied, thanks.
