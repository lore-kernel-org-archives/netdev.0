From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/2][pull request] Intel Wired LAN Driver Updates
 2015-05-07
Date: Sat, 09 May 2015 22:24:22 -0400 (EDT)
Message-ID: <20150509.222422.1964944250254329435.davem@davemloft.net>
References: <1431001293-19424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbEJCYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 22:24:24 -0400
In-Reply-To: <1431001293-19424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  7 May 2015 05:21:31 -0700

> This series contains updates to igb only.
> 
> Toshiaki provides two fixes for igb, first fixes an issue when changing
> the number of rings by ethtool which causes oops because of uninitialized
> pointers.  The second fix resolves a typo where tx_ring was used instead
> of the desired rx_ring.

Pulled, thanks Jeff.
