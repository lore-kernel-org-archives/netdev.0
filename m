From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] atl1e: Remove non-implementation of ethtool
 set_msglevel() operation
Date: Wed, 02 Dec 2009 22:15:13 -0800 (PST)
Message-ID: <20091202.221513.44955344.davem@davemloft.net>
References: <1259730618.21651.5.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jie.yang@atheros.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752903AbZLCGPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:15:06 -0500
In-Reply-To: <1259730618.21651.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 02 Dec 2009 05:10:18 +0000

> Unimplemented operations should not silently fail.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
