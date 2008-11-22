From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] enic: driver/firmware API updates
Date: Fri, 21 Nov 2008 21:28:24 -0800 (PST)
Message-ID: <20081121.212824.31086718.davem@davemloft.net>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
	<20081122003402.15540.44659.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54313
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751465AbYKVF2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 00:28:25 -0500
In-Reply-To: <20081122003402.15540.44659.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Fri, 21 Nov 2008 16:34:02 -0800

> enic: driver/firmware API updates
> 
> Add driver/firmware compatibility check.
> Update firmware notify cmd to honor notify area size.
> Add new version of init cmd.
> Add link_down_cnt to notify area to track link down count.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.
