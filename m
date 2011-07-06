From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Add GSO to vlan_features
 initialization
Date: Tue, 05 Jul 2011 20:44:31 -0700 (PDT)
Message-ID: <20110705.204431.1883807425791102260.davem@davemloft.net>
References: <4E13C3C4.40809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755958Ab1GFDoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 23:44:34 -0400
In-Reply-To: <4E13C3C4.40809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Wed, 06 Jul 2011 10:09:08 +0800

> Just add GSO to vlan_features initialization, and update comments.
> 
> When we set offload features, vlan_dev_fix_features() will do more check.
> In vlan_dev_fix_features(), final features is decided by
> features of real device and vlan_features of real device.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied to net-next-2.6
