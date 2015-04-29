From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/12] trivial: net: systemport: bcmsysport.h: fix 0x0x
 prefix
Date: Wed, 29 Apr 2015 14:56:49 -0400 (EDT)
Message-ID: <20150429.145649.326666924836876555.davem@davemloft.net>
References: <1430219491-5076-1-git-send-email-ao2@ao2.it>
	<1430219491-5076-11-git-send-email-ao2@ao2.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, f.fainelli@gmail.com, netdev@vger.kernel.org
To: ao2@ao2.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbbD2S4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:56:53 -0400
In-Reply-To: <1430219491-5076-11-git-send-email-ao2@ao2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Ospite <ao2@ao2.it>
Date: Tue, 28 Apr 2015 13:11:29 +0200

> Fix the 0x0x prefix in an integer constant.
> 
> In this case, while at it, also fix a typo (s/unitcast/unicast/).
> 
> Signed-off-by: Antonio Ospite <ao2@ao2.it>

Applied.
