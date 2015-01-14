From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdevice: Add missing parentheses in macro
Date: Wed, 14 Jan 2015 16:34:49 -0500 (EST)
Message-ID: <20150114.163449.1861047394880254499.davem@davemloft.net>
References: <1421221955-9505-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421221955-9505-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Wed, 14 Jan 2015 16:52:35 +0900

> For example, one could conceivably call
> 	for_each_netdev_in_bond_rcu(condition ? bond1 : bond2, slave)
> and get an unexpected result.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

Applied.
