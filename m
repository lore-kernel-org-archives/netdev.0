From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] r8169: remove "PHY reset until link up" log spam
Date: Fri, 02 Aug 2013 14:55:41 -0700 (PDT)
Message-ID: <20130802.145541.1520703852081330687.davem@davemloft.net>
References: <1375432615-7901-1-git-send-email-lekensteyn@gmail.com>
	<20130802174754.GA24369@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lekensteyn@gmail.com, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, nic_swsd@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab3HBVzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 17:55:42 -0400
In-Reply-To: <20130802174754.GA24369@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 2 Aug 2013 19:47:54 +0200

> Peter Wu <lekensteyn@gmail.com> :
>> This message was added in commit a7154cb8 (June 2004, [PATCH] r8169:
>> link handling and phy reset rework) and is printed every ten seconds
>> when no cable is connected and runtime power management is disabled.
>> (Before that commit, "Reset RTL8169s PHY" would be printed instead.)
>> 
>> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
