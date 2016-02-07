From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] be2net patch-set
Date: Sun, 07 Feb 2016 13:55:50 -0500 (EST)
Message-ID: <20160207.135550.254468372216752084.davem@davemloft.net>
References: <1454473163-18781-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbcBGSzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 13:55:53 -0500
In-Reply-To: <1454473163-18781-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Date: Wed,  3 Feb 2016 09:49:15 +0530

> v2 changes:
> 	Patch-4:	Changed a tab to space in be.h
> 	Patches-6,7,8:	Updated commit log summary line: benet --> be2net
> 
> Hi David,
> 
> The following patch set contains a few non-critical bug fixes. Please
> consider applying this to the net-next tree. Thanks.
> 
> Patch-1 fixes be_set_phys_id() ethtool function to return an error code.
> Patch-2 fixes a warning when some commands fail for VFs.
> Patch-3 fixes be_vlan_rem_vid() to verify vlan being removed is in the list.
> Patch-4 improves SRIOV queue distribution logic.
> Patch-5 avoids running self test on VFs.
> Patch-6 fixes error recovery in Lancer to clean up after moving to ready state.
> Patch-7 adds retry logic to error recovery in case of recovery failures
> Patch-8 fixes time interval used in eq delay computation routine

Series applied, thank you.
