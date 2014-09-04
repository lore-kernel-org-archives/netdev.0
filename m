From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] openvswitch: distinguish between the dropped and
 consumed skb
Date: Wed, 03 Sep 2014 20:51:45 -0700 (PDT)
Message-ID: <20140903.205145.1068969954345953948.davem@davemloft.net>
References: <1409737426-22245-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@noironetworks.com, pshelar@nicira.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbaIDDun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 23:50:43 -0400
In-Reply-To: <1409737426-22245-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed,  3 Sep 2014 17:43:45 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> distinguish between the dropped and consumed skb, not assume the skb
> is consumed always
> 
> Cc: Thomas Graf <tgraf@noironetworks.com>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thank you.
