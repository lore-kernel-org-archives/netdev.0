From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Pseudo-header required for the checksum of
 ICMPv6
Date: Wed, 24 Aug 2011 17:51:06 -0700 (PDT)
Message-ID: <20110824.175106.1479244833271913102.davem@davemloft.net>
References: <4E54BC49.6090506@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wcang@sfc.wide.ad.jp
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab1HYAvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:51:12 -0400
In-Reply-To: <4E54BC49.6090506@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Wed, 24 Aug 2011 16:54:33 +0800

> Checksum of ICMPv6 is not properly computed because the pseudo header is not used.
> Thus, the MLD packet gets dropped by the bridge.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> Reported-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>

Applied.
