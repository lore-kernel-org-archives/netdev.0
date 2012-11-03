From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: allow multicast packets on sub-8168f
 chipset.
Date: Sat, 03 Nov 2012 15:27:35 -0400 (EDT)
Message-ID: <20121103.152735.487365884571922769.davem@davemloft.net>
References: <20121101220847.GA7708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com,
	faceprint@faceprint.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab2KCT1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:27:37 -0400
In-Reply-To: <20121101220847.GA7708@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 1 Nov 2012 23:08:47 +0100

> From: Nathan Walp <faceprint@faceprint.com>
> 
> RTL_GIGA_MAC_VER_35 includes no multicast hardware filter.
> 
> Signed-off-by: Nathan Walp <faceprint@faceprint.com>
> Suggested-by: Hayes Wang <hayeswang@realtek.com>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
