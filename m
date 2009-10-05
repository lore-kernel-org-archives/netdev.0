From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] ethtool: Remove support for obsolete string query
 operations
Date: Mon, 05 Oct 2009 00:13:48 -0700 (PDT)
Message-ID: <20091005.001348.168706908.davem@davemloft.net>
References: <1254432783.2735.29.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758006AbZJEHNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:13:53 -0400
In-Reply-To: <1254432783.2735.29.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 01 Oct 2009 22:33:03 +0100

> The in-tree implementations have all been converted to
> get_sset_count().
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6
