From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bridge: vlan: failure path and comment
 fixes
Date: Mon, 02 Nov 2015 15:40:40 -0500 (EST)
Message-ID: <20151102.154040.241280609604044694.davem@davemloft.net>
References: <1446223580-1464-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	nikolay@cumulusnetworks.com, idosch@mellanox.com,
	roopa@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbbKBUkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:40:42 -0500
In-Reply-To: <1446223580-1464-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 30 Oct 2015 17:46:18 +0100

> This is a set from Ido which takes care of one failure path error in
> nbp_vlan_init (patch 1) and a few comment errors (patch 2).
> I must admit I didn't expect the port init continues after a vlan init
> failure but should've checked to make sure. Thanks to Ido for catching
> these!

Series applied, thanks.
