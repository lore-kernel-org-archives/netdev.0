From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6.24][NETNS][patch 1/3] fix export symbols
Date: Wed, 12 Sep 2007 05:53:07 -0700 (PDT)
Message-ID: <20070912.055307.23027518.davem@davemloft.net>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
	<20070912124414.640551634@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org, markn@au1.ibm.com, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:36386
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965897AbXILMzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:55:01 -0400
In-Reply-To: <20070912124414.640551634@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dlezcano@fr.ibm.com
Date: Wed, 12 Sep 2007 14:38:12 +0200

> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Add the appropriate EXPORT_SYMBOLS for proc_net_create,
> proc_net_fops_create and proc_net_remove to fix errors when
> compiling allmodconfig
> 
> Signed-off-by: Mark Nelson <markn@au1.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Applied to net-2.6.24, thanks.

Why aren't you signing off on these patches?  Please
do so in the future.

Because "From: " usually means you are the patch author, and I can't
tell who wrote these patches, you or these other people listed in the
signoff area.
