From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] be2net: patch set
Date: Mon, 14 Apr 2014 13:42:05 -0400 (EDT)
Message-ID: <20140414.134205.1686565052577645503.davem@davemloft.net>
References: <1397472161-28685-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaDNRmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 13:42:07 -0400
In-Reply-To: <1397472161-28685-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 14 Apr 2014 16:12:39 +0530

> Patch 1/2 is a v2 of a patch that was submitted earlier (as a part of a
> different patch-set). v2 incorporates a suggestion given by David Laight
> for how long to poll for pending TX completions while disabling a device.
> 
> Patch 2/2 fixes a crash in be_remove()->be_close()
> path after be2net has aborted an EEH error recovery
> due to a permanant failure.

Series applied, thank you.
