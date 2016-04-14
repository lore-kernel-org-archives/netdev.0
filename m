From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: eliminate holes in ip_tunnel
Date: Thu, 14 Apr 2016 01:16:12 -0400 (EDT)
Message-ID: <20160414.011612.1080957925742347525.davem@davemloft.net>
References: <20160413170221.6f158a74@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbcDNFQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 01:16:17 -0400
In-Reply-To: <20160413170221.6f158a74@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 13 Apr 2016 17:02:21 -0700

> The structure can be packed denser by doing minor rearrangement
> of existing elements.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thank you.
