From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: unify macvlan_pcpu_stats and
 vlan_pcpu_stats
Date: Sat, 04 Jan 2014 20:12:11 -0500 (EST)
Message-ID: <20140104.201211.770660095970227474.davem@davemloft.net>
References: <1388816554-17366-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152AbaAEBMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:12:12 -0500
In-Reply-To: <1388816554-17366-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sat,  4 Jan 2014 14:22:34 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> They are same, so unify them as one; since macvlan is a kind of vlan,
> vlan_pcpu_stats should be a proper name for vlan and macvlan.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
