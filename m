From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] atl1c: update hardware settings - v2
Date: Thu, 19 Apr 2012 20:17:05 -0400 (EDT)
Message-ID: <20120419.201705.1717095047671342251.davem@davemloft.net>
References: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com
To: xiong@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388Ab2DTARI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 20:17:08 -0400
In-Reply-To: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: xiong <xiong@qca.qualcomm.com>
Date: Thu, 19 Apr 2012 16:01:20 +0800

> This update contains a serial of patches, most of them are hardware
> settings related. register definitions are refined (or removed if
> meaningless) for each patch.
> 
> This is the second serial patches, after reviewed/applied the third
> serial will be out.
> 
> The patches have addressed all sparse and checkpatch warnings.
> 
> Following NICs are tested:
> AR8131/AR8132/AR8151A/AR8152A/AR8152B
> Test item includes:
> build/install/uninstall/dhcp/ping/iperf/wol/reboot/etc.

Series applied, thanks.
