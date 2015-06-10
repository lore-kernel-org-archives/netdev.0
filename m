From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 20150609
Date: Tue, 09 Jun 2015 20:24:23 -0700 (PDT)
Message-ID: <20150609.202423.333671059701531273.davem@davemloft.net>
References: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbbFJDYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 23:24:25 -0400
In-Reply-To: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue,  9 Jun 2015 12:50:13 +0200

> this is our last batch of patches intended for net-next.
> 
> You have 4 patches from Sven Eckelmann, most notably: 1/7 changes
> our hash implementation to use the Jenkins one provided by the kernel;
> 4/7 reorganizes the way we include headers so that each .c file has
> all it requires without relying on any fancy including order.
> 
> Then there are three patches from me: 2/7 is slightly changing the
> macros we use to handle sysfs files to make them more flexible for
> future uses; 3/7 is extending the "routing protocol API" so that new
> implementations can have more control over
> the neigh_node internal structures; 7/7 ensures that all the per-VLAN
> internal structures are updated when the MAC address is changed by the
> user.
> 
> Please pull if everything is fine!

Pulled, thanks Antonio.
