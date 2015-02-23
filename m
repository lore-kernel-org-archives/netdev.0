From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/9] be2net: patch set
Date: Mon, 23 Feb 2015 15:08:56 -0500 (EST)
Message-ID: <20150223.150856.1853935850244224341.davem@davemloft.net>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbbBWUI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 15:08:58 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 23 Feb 2015 04:20:07 -0500

> Hi Dave, the following patch set reduces code duplication
> in probe/pci-resume/eeh-resume and remove/pci-suspend/eeh-error and UE-error
> detect/recovery paths. New helper routines have been introduced for this
> purpose. Pls apply this set to the net-next tree. Thanks!

Series applied, thanks.
