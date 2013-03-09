From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tunnel: Inherit NETIF_F_SG for
 hw_enc_features.
Date: Sat, 09 Mar 2013 16:11:04 -0500 (EST)
Message-ID: <20130309.161104.1233402396279629371.davem@davemloft.net>
References: <1362684488-1822-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab3CIVK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 16:10:58 -0500
In-Reply-To: <1362684488-1822-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu,  7 Mar 2013 11:28:08 -0800

> Inherit scatergather feature for tunnel devices to avoid
> copy for TSO packets of tunneling device like GRE.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
