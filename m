From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/6] i40e: Add VF port representator support
 or SR-IOV VFs
Date: Thu, 29 Dec 2016 21:53:56 -0500 (EST)
Message-ID: <20161229.215356.2143143534347167491.davem@davemloft.net>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753349AbcL3Cx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 21:53:58 -0500
In-Reply-To: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Date: Thu, 29 Dec 2016 22:20:57 -0800

> - Patch 1 introduces devlink interface to get/set the mode of SRIOV switch.
> - Patch 2 adds support to create VF port representor(VFPR) netdevs associated
>   with SR-IOV VFs that can be used to control/configure VFs from PF name space.
> - Patch 3 enables syncing link state between VFs and VFPRs.
> - Patch 4 adds a new type to metadata_dst to allow passing VF id to lower device.
> - Patch 5 adds TX and RX support to VFPR netdevs.
> - Patch 6 enables HW and SW VFPR statistics to be exposed via netlink on VFPR
>   netdevs.

Patch 4 did not show up on the lists.

The computer you did this work on is configured with a time in the future.
