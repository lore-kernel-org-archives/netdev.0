From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rndis_host: Quirky devices are still
 'point-to-point'
Date: Thu, 14 Apr 2011 23:24:00 -0700 (PDT)
Message-ID: <20110414.232400.193696727.davem@davemloft.net>
References: <1302785461.5282.686.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752769Ab1DOGYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 02:24:36 -0400
In-Reply-To: <1302785461.5282.686.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 14 Apr 2011 13:51:01 +0100

> My changes in commit 4d42d417be75d750b82798922b6e775915e11bce were
> written some time before the introduction of FLAG_POINTTOPOINT, so
> didn't include that flag in the new driver_info.  Change the new
> driver_info to be consistent.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied, thanks Ben.
