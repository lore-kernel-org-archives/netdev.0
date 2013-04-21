From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vlan: fix dummy function signatures for
 CONFIG_VLAN=n
Date: Sun, 21 Apr 2013 15:57:19 -0400 (EDT)
Message-ID: <20130421.155719.1845805379958137056.davem@davemloft.net>
References: <1366537901-559-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemlofft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223Ab3DUT5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 15:57:20 -0400
In-Reply-To: <1366537901-559-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 21 Apr 2013 11:51:41 +0200

> Fix up some function signatures for CONFIG_VLAN=n that were missed during
> the 802.1ad support patches.
> 
> Found by the kbuild robot.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
