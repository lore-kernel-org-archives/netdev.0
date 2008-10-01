From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 09/16] Export UDP socket lookup function
Date: Wed, 01 Oct 2008 07:48:34 -0700 (PDT)
Message-ID: <20081001.074834.207976012.davem@davemloft.net>
References: <20081001142431.4893.48078.stgit@este>
	<20081001142431.4893.2247.stgit@este>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752323AbYJAOsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:48:46 -0400
In-Reply-To: <20081001142431.4893.2247.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Wed, 01 Oct 2008 16:24:31 +0200

> The iptables tproxy code has to be able to do UDP socket hash lookups,
> so we have to provide an exported lookup function for this purpose.
> 
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

Applied to net-next-2.6
