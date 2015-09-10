From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ether: add IEEE 1722 ethertype - TSN
Date: Wed, 09 Sep 2015 21:53:33 -0700 (PDT)
Message-ID: <20150909.215333.357280642280867991.davem@davemloft.net>
References: <1441790792-21036-1-git-send-email-henrik@austad.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: henrik@austad.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbIJExe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 00:53:34 -0400
In-Reply-To: <1441790792-21036-1-git-send-email-henrik@austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henrik Austad <henrik@austad.us>
Date: Wed,  9 Sep 2015 11:26:32 +0200

> IEEE 1722 describes AVB (later renamed to TSN - Time Sensitive
> Networking), a protocol, encapsualtion and synchronization to utilize
> standard networks for audio/video (and later other time-sensitive)
> streams.
> 
> This standard uses ethertype 0x22F0.
> 
> http://standards.ieee.org/develop/regauth/ethertype/eth.txt
> 
> This is a respin of a previous patch ("ether: add AVB frame type
> ETH_P_AVB")
> 
> CC: "David S. Miller" <davem@davemloft.net>
> CC: netdev@vger.kernel.org
> CC: linux-api@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> Signed-off-by: Henrik Austad <henrik@austad.us>

Applied.
