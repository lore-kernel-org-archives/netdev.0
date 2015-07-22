From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bnx2x: update FW, rebrand and more
Date: Wed, 22 Jul 2015 10:47:41 -0700 (PDT)
Message-ID: <20150722.104741.204995012517418090.davem@davemloft.net>
References: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933142AbbGVRrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 13:47:42 -0400
In-Reply-To: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 22 Jul 2015 09:16:21 +0300

> This patch series does several things - it updates the bnx2x FW into
> 7.12.30 which both contains some small fixes as well as opening the door
> for several new features for the device - mainly vxlan/geneve offloads
> and vlan filtering offload.
> It then adds a new Multi-function mode [BD] which requires this FW in
> order to operate.
> 
> In addition, this finally rebrands the driver from a 'broadcom' driver
> into a 'qlogic' driver [although it would still reside under Broadcom's
> tree in the kernel].

Series applied, thanks.
