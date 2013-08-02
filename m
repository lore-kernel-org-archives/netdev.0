From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] r8169: remove "PHY reset until link up" log spam
Date: Fri, 2 Aug 2013 19:47:54 +0200
Message-ID: <20130802174754.GA24369@electric-eye.fr.zoreil.com>
References: <1375432615-7901-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50647 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358Ab3HBRsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 13:48:10 -0400
Content-Disposition: inline
In-Reply-To: <1375432615-7901-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
> This message was added in commit a7154cb8 (June 2004, [PATCH] r8169:
> link handling and phy reset rework) and is printed every ten seconds
> when no cable is connected and runtime power management is disabled.
> (Before that commit, "Reset RTL8169s PHY" would be printed instead.)
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
