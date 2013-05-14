From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Avoid double insertion of vlan tags.
Date: Tue, 14 May 2013 11:32:56 -0700 (PDT)
Message-ID: <20130514.113256.743446917212526751.davem@davemloft.net>
References: <99cc7c56-50d0-448a-8792-5661cdf030d9@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757781Ab3ENSc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 14:32:57 -0400
In-Reply-To: <99cc7c56-50d0-448a-8792-5661cdf030d9@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sarveshwar.bandi@emulex.com>
Date: Tue, 14 May 2013 11:58:20 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Fix to avoid double insertion of  vlan tags into the packet while
> handling an asic workaroud (issue introduced by net next Commit bc0c340)
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Applied.
