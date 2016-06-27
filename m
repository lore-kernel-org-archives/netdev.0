From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/5] be2net: patch set
Date: Mon, 27 Jun 2016 04:06:50 -0400 (EDT)
Message-ID: <20160627.040650.167517085618093609.davem@davemloft.net>
References: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbcF0IHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 04:07:16 -0400
In-Reply-To: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Wed, 22 Jun 2016 08:54:52 -0400

> Hi Dave, pls consider commiting the following patches to the net-next tree.
> Thanks!
> 
> Patch 1 replaces the be_max_eqs() macro with two new macros called
> be_max_nic_eqs() and be_max_func_eqs() to clear confusion in that part
> of the code.
> 
> Patch 2 adds support to configure asymmetric number of rx/tx queues via
> ethtool set-channels option.
> 
> Patch 3 disables EVB when VFs are not enabled on a BE3 SR-IOV config to
> avoid the broadcast echo problem.
> 
> Patch 4 updates copyright markings in be2net src files
> 
> Patch 5 updates the be2net maintainers' list

Series applied, thanks.
