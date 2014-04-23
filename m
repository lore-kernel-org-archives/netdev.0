From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 2/2] be2net: Support for configurable RSS
 hash key
Date: Tue, 22 Apr 2014 21:29:00 -0400 (EDT)
Message-ID: <20140422.212900.1217135773929892370.davem@davemloft.net>
References: <1398074880-13300-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	<d3c0c9d4-8cdc-4ffe-abaa-55c4579d9df4@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724AbaDWB3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 21:29:01 -0400
In-Reply-To: <d3c0c9d4-8cdc-4ffe-abaa-55c4579d9df4@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Date: Mon, 21 Apr 2014 15:38:00 +0530

> This be2net patch implements the get/set_rxfh() ethtool hooks.
> RSS_CONFIG device command is invoked to set hashkey and indirection table.
> It also uses an initial random value for RSS hash key instead of a
> hard-coded value as hard-coded values for a hash-key are usually
> considered a security risk.
> 
> Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>

Applied.
