From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: implement vlan filter enable and
 disable
Date: Sun, 18 Jun 2017 23:53:29 -0400 (EDT)
Message-ID: <20170618.235329.870474653336509002.davem@davemloft.net>
References: <20170618194134.GA1249@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdFSDxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 23:53:45 -0400
In-Reply-To: <20170618194134.GA1249@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Sun, 18 Jun 2017 12:41:34 -0700

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> Add implementation to support ethtool -K ethX rx-vlan-filter on/off.
> Rename OCTNET_CMD_ENABLE_VLAN_FILTER command to OCTNET_CMD_VLAN_FILTER_CTL
> and add OCTNET_CMD_VLAN_FILTER_ENABLE and OCTNET_CMD_VLAN_FILTER_DISABLE
> parameters so that it can be used to enable or disable the filter.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
