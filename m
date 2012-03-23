From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next][v3] bonding: remove entries for master_ip and
 vlan_ip and query devices instead
Date: Thu, 22 Mar 2012 22:36:53 -0400 (EDT)
Message-ID: <20120322.223653.1739940863244968264.davem@davemloft.net>
References: <1332468869-17553-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.zeidler@nsn.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447Ab2CWChC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 22:37:02 -0400
In-Reply-To: <1332468869-17553-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Thu, 22 Mar 2012 22:14:29 -0400

> The following patch aimed to resolve an issue where secondary, tertiary,
> etc. addresses added to bond interfaces could overwrite the
> bond->master_ip and vlan_ip values.
 ...
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied.
