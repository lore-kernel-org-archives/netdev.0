From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Fix driver load for VFs for Lancer
Date: Thu, 07 Jun 2012 13:19:47 -0700 (PDT)
Message-ID: <20120607.131947.1839925289300302583.davem@davemloft.net>
References: <e4b55390-7f60-4365-9203-fde4c661e339@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: padmanabh.ratnakar@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902Ab2FGUTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:19:47 -0400
In-Reply-To: <e4b55390-7f60-4365-9203-fde4c661e339@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Date: Thu, 7 Jun 2012 20:07:08 +0530

> Permanent MAC is wrongly supplied in create iface command. Call the
> command with no MAC address and then MAC address should be later queried
> and applied.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>

Applied.
