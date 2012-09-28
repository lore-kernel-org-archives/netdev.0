From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] smsc75xx: enhancements (V2)
Date: Fri, 28 Sep 2012 18:39:58 -0400 (EDT)
Message-ID: <20120928.183958.1722323968003314458.davem@davemloft.net>
References: <1348829873-30779-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964774Ab2I1WkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 18:40:01 -0400
In-Reply-To: <1348829873-30779-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Fri, 28 Sep 2012 11:57:49 +0100

> This patchset makes a few enhancements to the smsc75xx driver
> including improved power saving during suspend and support for
> magic packet wol.
> 
> This patchset has been rebased against net-next/master but I
> believe the first patch has already been included in net/master.
> 
> Steve Glendinning (4):
>   smsc75xx: fix resume after device reset
>   smsc75xx: add explicit test that device is READY
>   smsc75xx: enable power saving mode during system suspend
>   smsc75xx: add wol magic packet support

I already applied the first patch, a bug fix, to 'net' and pushed
it off to Linus.  Maybe you didn't see that.

The rest I put into net-next, thanks.
